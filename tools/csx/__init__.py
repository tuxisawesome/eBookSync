"""Reference implementation of the eBookSync .csx pipeline.

This package is the desktop counterpart to web/js/*.js: it converts comic JPEGs
into the layered, banded, ZX0-compressed container the calculator reads, and can
emit the .8xv appvars to load into CEmu or send with TI Connect CE.

The browser is the production converter; this exists so the codec can be
developed and verified without a calculator in the loop.
"""
