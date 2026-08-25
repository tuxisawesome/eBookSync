/*
 * ZX0 compression, ported from Einar Saukas' reference implementation
 * (BSD-3-Clause; see tools/vendor/zx0/LICENSE).
 *
 * This produces the default, non-"classic" forward stream, which is what the
 * CE toolchain's zx0_Decompress consumes. Output is byte-identical to the
 * upstream `zx0` tool -- tools/hosttest checks that.
 *
 * The optimal parser is O(size * offsetLimit) and runs over every band of every
 * strip, so the block pool lives in typed arrays and reuses dead blocks through
 * the same reference-counted free list the C version uses. Without that reuse a
 * single 5 KB band would allocate millions of objects.
 */

const NIL = -1;
const INITIAL_OFFSET = 1;
export const MAX_OFFSET = 32640;

/*
 * Cap on the match window. The parse cost is linear in this, and bands are a
 * few KB of 4bpp image data whose useful matches sit within a handful of
 * scanlines. Measured on the fit-width layer of assets/strip1.jpg, 1024 costs
 * 1.2% in size over an unbounded window and runs three times faster. See
 * docs/FORMAT.md.
 */
export const DEFAULT_OFFSET_LIMIT = 1024;

/* Block pool. Grown on demand and reused across calls. */
let poolCapacity = 0;
let poolCount = 0;
let bits, blockIndex, blockOffset, chain, ghostChain, references;
let ghostRoot = NIL;

function growPool(capacity) {
  const next = Math.max(capacity, poolCapacity * 2, 1 << 14);
  const grow = (old, kind) => {
    const array = new kind(next);
    if (old) array.set(old);
    return array;
  };
  bits = grow(bits, Int32Array);
  blockIndex = grow(blockIndex, Int32Array);
  blockOffset = grow(blockOffset, Int32Array);
  chain = grow(chain, Int32Array);
  ghostChain = grow(ghostChain, Int32Array);
  references = grow(references, Int32Array);
  poolCapacity = next;
}

function resetPool() {
  poolCount = 0;
  ghostRoot = NIL;
}

function allocate(blockBits, index, offset, chainTo) {
  let ptr;
  if (ghostRoot !== NIL) {
    ptr = ghostRoot;
    ghostRoot = ghostChain[ptr];
    const previous = chain[ptr];
    if (previous !== NIL && --references[previous] === 0) {
      ghostChain[previous] = ghostRoot;
      ghostRoot = previous;
    }
  } else {
    if (poolCount === poolCapacity) growPool(poolCapacity + 1);
    ptr = poolCount++;
  }
  bits[ptr] = blockBits;
  blockIndex[ptr] = index;
  blockOffset[ptr] = offset;
  if (chainTo !== NIL) references[chainTo]++;
  chain[ptr] = chainTo;
  references[ptr] = 0;
  return ptr;
}

function assign(slots, position, block) {
  references[block]++;
  const previous = slots[position];
  if (previous !== NIL && --references[previous] === 0) {
    ghostChain[previous] = ghostRoot;
    ghostRoot = previous;
  }
  slots[position] = block;
}

function eliasGammaBits(value) {
  let count = 1;
  while ((value >>= 1)) count += 2;
  return count;
}

function offsetCeiling(index, offsetLimit) {
  if (index > offsetLimit) return offsetLimit;
  return index < INITIAL_OFFSET ? INITIAL_OFFSET : index;
}

function optimize(input, offsetLimit) {
  const size = input.length;
  let maxOffset = offsetCeiling(size - 1, offsetLimit);

  const lastLiteral = new Int32Array(maxOffset + 1).fill(NIL);
  const lastMatch = new Int32Array(maxOffset + 1).fill(NIL);
  const optimal = new Int32Array(size).fill(NIL);
  const matchLength = new Int32Array(maxOffset + 1);
  const bestLength = new Int32Array(size);

  resetPool();
  if (!poolCapacity) growPool(1 << 14);
  if (size > 2) bestLength[2] = 2;

  assign(lastMatch, INITIAL_OFFSET, allocate(-1, -1, INITIAL_OFFSET, NIL));

  for (let index = 0; index < size; index++) {
    let bestLengthSize = 2;
    maxOffset = offsetCeiling(index, offsetLimit);

    for (let offset = 1; offset <= maxOffset; offset++) {
      if (index !== 0 && index >= offset && input[index] === input[index - offset]) {
        /* copy from last offset */
        if (lastLiteral[offset] !== NIL) {
          const length = index - blockIndex[lastLiteral[offset]];
          const cost = bits[lastLiteral[offset]] + 1 + eliasGammaBits(length);
          assign(lastMatch, offset, allocate(cost, index, offset, lastLiteral[offset]));
          if (optimal[index] === NIL || bits[optimal[index]] > cost) {
            assign(optimal, index, lastMatch[offset]);
          }
        }

        /* copy from new offset */
        if (++matchLength[offset] > 1) {
          if (bestLengthSize < matchLength[offset]) {
            let cost = bits[optimal[index - bestLength[bestLengthSize]]]
              + eliasGammaBits(bestLength[bestLengthSize] - 1);
            do {
              bestLengthSize++;
              const other = bits[optimal[index - bestLengthSize]]
                + eliasGammaBits(bestLengthSize - 1);
              if (other <= cost) {
                bestLength[bestLengthSize] = bestLengthSize;
                cost = other;
              } else {
                bestLength[bestLengthSize] = bestLength[bestLengthSize - 1];
              }
            } while (bestLengthSize < matchLength[offset]);
          }

          const length = bestLength[matchLength[offset]];
          const cost = bits[optimal[index - length]] + 8
            + eliasGammaBits(Math.floor((offset - 1) / 128) + 1)
            + eliasGammaBits(length - 1);
          if (lastMatch[offset] === NIL || blockIndex[lastMatch[offset]] !== index
              || bits[lastMatch[offset]] > cost) {
            assign(lastMatch, offset, allocate(cost, index, offset, optimal[index - length]));
            if (optimal[index] === NIL || bits[optimal[index]] > cost) {
              assign(optimal, index, lastMatch[offset]);
            }
          }
        }
      } else {
        /* copy literals */
        matchLength[offset] = 0;
        if (lastMatch[offset] !== NIL) {
          const length = index - blockIndex[lastMatch[offset]];
          const cost = bits[lastMatch[offset]] + 1 + eliasGammaBits(length) + length * 8;
          assign(lastLiteral, offset, allocate(cost, index, 0, lastMatch[offset]));
          if (optimal[index] === NIL || bits[optimal[index]] > cost) {
            assign(optimal, index, lastLiteral[offset]);
          }
        }
      }
    }
  }

  return optimal[size - 1];
}

function emit(optimalTail, input) {
  const output = new Uint8Array(Math.floor((bits[optimalTail] + 25) / 8));
  let outputIndex = 0;
  let inputIndex = 0;
  let bitIndex = 0;
  let bitMask = 0;
  /* The first literal indicator is backtracked onto a byte that does not exist
   * yet, which is exactly how the reference encoder elides it. */
  let backtrack = true;

  const writeByte = (value) => { output[outputIndex++] = value; };

  const writeBit = (value) => {
    if (backtrack) {
      if (value) output[outputIndex - 1] |= 1;
      backtrack = false;
      return;
    }
    if (!bitMask) {
      bitMask = 128;
      bitIndex = outputIndex;
      writeByte(0);
    }
    if (value) output[bitIndex] |= bitMask;
    bitMask >>= 1;
  };

  const writeGamma = (value, invert) => {
    let i = 2;
    while (i <= value) i <<= 1;
    i >>= 1;
    while ((i >>= 1)) {
      writeBit(0);
      writeBit(invert ? (value & i ? 0 : 1) : (value & i ? 1 : 0));
    }
    writeBit(1);
  };

  /* Un-reverse the chain the optimizer built backwards. */
  let previous = NIL;
  let current = optimalTail;
  while (current !== NIL) {
    const next = chain[current];
    chain[current] = previous;
    previous = current;
    current = next;
  }

  let lastOffset = INITIAL_OFFSET;
  let prev = previous;
  for (let block = chain[previous]; block !== NIL; prev = block, block = chain[block]) {
    const length = blockIndex[block] - blockIndex[prev];

    if (!blockOffset[block]) {
      writeBit(0);
      writeGamma(length, false);
      for (let i = 0; i < length; i++) writeByte(input[inputIndex++]);
    } else if (blockOffset[block] === lastOffset) {
      writeBit(0);
      writeGamma(length, false);
      inputIndex += length;
    } else {
      writeBit(1);
      writeGamma(Math.floor((blockOffset[block] - 1) / 128) + 1, true);
      writeByte((127 - ((blockOffset[block] - 1) % 128)) << 1);
      /* The first length bit rides in bit 0 of the offset byte just written. */
      backtrack = true;
      writeGamma(length - 1, false);
      inputIndex += length;
      lastOffset = blockOffset[block];
    }
  }

  writeBit(1);
  writeGamma(256, true);

  return output.subarray(0, outputIndex);
}

/** Compress bytes into a standalone ZX0 stream. */
export function compress(data, offsetLimit = DEFAULT_OFFSET_LIMIT) {
  const input = data instanceof Uint8Array ? data : new Uint8Array(data);
  if (!input.length) return new Uint8Array(0);
  return emit(optimize(input, offsetLimit), input);
}

/** Decode a ZX0 stream. Only used to self-check; the calculator has its own. */
export function decompress(data) {
  let pos = 0;
  let bitMask = 0;
  let bitValue = 0;
  let lastByte = 0;
  let backtrack = false;
  const out = [];

  const readByte = () => (lastByte = data[pos++]);
  const readBit = () => {
    if (backtrack) {
      backtrack = false;
      return lastByte & 1;
    }
    bitMask >>= 1;
    if (bitMask === 0) {
      bitMask = 128;
      bitValue = readByte();
    }
    return bitValue & bitMask ? 1 : 0;
  };
  const readGamma = (inverted) => {
    let value = 1;
    while (!readBit()) value = (value << 1) | (readBit() ^ (inverted ? 1 : 0));
    return value;
  };
  const copy = (offset, length) => {
    for (let i = 0; i < length; i++) out.push(out[out.length - offset]);
  };

  let offset = 1;
  for (;;) {
    for (let n = readGamma(false); n > 0; n--) out.push(readByte());

    if (!readBit()) {
      copy(offset, readGamma(false));
      if (!readBit()) continue;
    }

    for (;;) {
      offset = readGamma(true);
      if (offset === 256) return new Uint8Array(out);
      offset = offset * 128 - (readByte() >> 1);
      backtrack = true;
      copy(offset, readGamma(false) + 1);
      if (!readBit()) break;
    }
  }
}
