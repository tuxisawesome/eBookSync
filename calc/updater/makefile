# ----------------------------
# Makefile Options
# ----------------------------

NAME = CSUP
DESCRIPTION = "eBookSync updater"
COMPRESSED = YES
ARCHIVED = YES

# The manifest and chunk format has one implementation, shared with the reader,
# so the two halves of an update cannot disagree about it.
CFLAGS = -Wall -Wextra -Oz -I../src
CXXFLAGS = -Wall -Wextra -Oz -I../src

EXTRA_CSOURCES = ../src/update.c ../src/crc32.c

# ----------------------------

include $(shell cedev-config --makefile)
