# ----------------------------
# Makefile Options
# ----------------------------

NAME = COMICS
DESCRIPTION = "eBookSync comic reader"
COMPRESSED = YES
ARCHIVED = YES

CFLAGS = -Wall -Wextra -Oz
CXXFLAGS = -Wall -Wextra -Oz

# ----------------------------

# The About page's text lives in about.txt at the repository root. The
# calculator cannot read the repository, so bake it into a header on every
# build; editing about.txt is all that is needed.
$(shell sh ../tools/make_about.sh ../about.txt src/about.h)

include $(shell cedev-config --makefile)
