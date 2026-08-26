#!/bin/sh
#
# Turn about.txt into a C header the reader can display.
#
# The calculator has no filesystem to read the repository from, so the text is
# baked into the program at build time. calc/makefile runs this on every build,
# so editing about.txt is enough -- there is nothing to regenerate by hand.
#
#   tools/make_about.sh about.txt calc/src/about.h

set -e

source_file="${1:?usage: make_about.sh <about.txt> <about.h>}"
target="${2:?usage: make_about.sh <about.txt> <about.h>}"

{
    echo "/*"
    echo " * Generated from about.txt by tools/make_about.sh. Do not edit."
    echo " *"
    echo " * The reader draws these with the built-in graphx font, which is ASCII"
    echo " * only and 8 pixels wide, so lines longer than 40 characters run off the"
    echo " * side of the screen."
    echo " */"
    echo
    echo "#ifndef ABOUT_H"
    echo "#define ABOUT_H"
    echo
    echo "static const char *const about_text[] = {"

    # Escape backslashes and quotes, strip carriage returns, and wrap each line
    # as a string literal.
    sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\r$//' -e 's/^/    "/' -e 's/$/",/' \
        "$source_file"

    echo "};"
    echo
    echo "#define ABOUT_LINES (sizeof about_text / sizeof *about_text)"
    echo
    echo "#endif /* ABOUT_H */"
} > "$target"
