/*
 * Talking to the chat relay.
 *
 * The relay is a separate service (see server/README.md), reached over HTTPS
 * from wherever this page is served. It has to be HTTPS: this page is on GitHub
 * Pages, and a browser will not let an HTTPS page call a plain-HTTP server.
 *
 * No DOM in here, so the host tests can drive it the way they drive link.js.
 */

export class RelayError extends Error {}
export class Unauthorised extends RelayError {}

/** Trim a pasted address into an origin this can build URLs on. */
export function normaliseUrl(raw) {
  const text = String(raw || '').trim();
  if (!text) return '';

  const withScheme = /^https?:\/\//i.test(text) ? text : `https://${text}`;
  try {
    const url = new URL(withScheme);
    return url.origin + url.pathname.replace(/\/+$/, '');
  } catch {
    throw new RelayError(`"${raw}" is not an address`);
  }
}

export class Relay {
  constructor(baseUrl, token = null, { fetcher = globalThis.fetch } = {}) {
    this.baseUrl = normaliseUrl(baseUrl);
    this.token = token;
    /* Injectable so the tests can run without a network, and so a future
     * caller can add a timeout without this file knowing about it. */
    this.fetcher = fetcher;
  }

  async #call(path, { method = 'GET', body = null } = {}) {
    const headers = {};
    if (this.token) headers.Authorization = `Bearer ${this.token}`;
    if (body) headers['Content-Type'] = 'application/json';

    let response;
    try {
      response = await this.fetcher(`${this.baseUrl}${path}`, {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
      });
    } catch (error) {
      /* fetch rejects for DNS, TLS, a blocked mixed-content request and a
       * missing CORS header alike, and does not say which. Saying so is more
       * use than repeating the browser's one-word message. */
      throw new RelayError(`could not reach ${this.baseUrl}: ${error.message}. `
        + 'Check the address, that it is https, and that this page\'s origin is in '
        + 'the relay\'s EOS_ALLOWED_ORIGINS.');
    }

    if (response.status === 401) throw new Unauthorised('signed out of the relay');

    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new RelayError(data.error || `relay said ${response.status}`);
    return data;
  }

  static async signIn(baseUrl, username, password, options = {}) {
    const relay = new Relay(baseUrl, null, options);
    const data = await relay.#call('/api/login', {
      method: 'POST',
      body: { username, password, label: 'sync page' },
    });
    relay.token = data.token;
    return { relay, user: data.user };
  }

  me() {
    return this.#call('/api/me');
  }

  roster() {
    return this.#call('/api/roster');
  }

  messagesSince(cursor) {
    return this.#call(`/api/messages?since=${Number(cursor) || 0}`);
  }

  send(conversationId, body, clientId) {
    return this.#call('/api/messages', {
      method: 'POST',
      body: { conversationId, body, clientId },
    });
  }

  /**
   * Hand over what the calculator queued.
   *
   * Every message carries the clientId minted for it, so this is safe to repeat
   * -- which matters, because the calculator's outbox is cleared once the
   * messages are stored here, not once they reach the relay.
   */
  sendBatch(messages, { fromCalculator = true } = {}) {
    return this.#call('/api/messages/batch', {
      method: 'POST',
      body: { fromCalculator, messages },
    });
  }

  noteCalculatorSync() {
    return this.#call('/api/calc/sync', { method: 'POST', body: {} });
  }
}

/**
 * The relay's idempotency key for something typed on the calculator.
 *
 * The calculator does not know its own account, so it counts: a sequence number
 * that never repeats, kept in its conversation table. Pairing that with the
 * account this page is signed in as gives a key that is stable across retries
 * and unique across people.
 */
export function calculatorClientId(userId, seq) {
  return `calc-${userId}-${seq}`;
}

/** The same, for something typed here. */
export function pageClientId(userId) {
  return `page-${userId}-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`;
}
