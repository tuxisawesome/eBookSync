#!/bin/sh
#
# Turn calc/BUILD into a C header, so the reader can say which build it is.
#
# The number is what the sync page compares against web/eos/build.json to decide
# whether it has something newer to push. It is a plain integer in a file rather
# than a git count so that a working tree that has not been committed yet still
# produces a build the page can reason about.
#
#   tools/make_build.sh calc/BUILD calc/src/build.h

set -e

source_file="${1:?usage: make_build.sh <BUILD> <build.h>}"
target="${2:?usage: make_build.sh <BUILD> <build.h>}"

build=$(tr -cd '0-9' < "$source_file")
: "${build:?calc/BUILD does not contain a number}"

{
    echo "/*"
    echo " * Generated from calc/BUILD by tools/make_build.sh. Do not edit."
    echo " */"
    echo
    echo "#ifndef BUILD_H"
    echo "#define BUILD_H"
    echo
    echo "#define EOS_BUILD $build"
    echo
    echo "#endif /* BUILD_H */"
} > "$target"
