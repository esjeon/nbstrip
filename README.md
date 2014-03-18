
nbstrip - Mathematica notebook cleaner
======================================

This Mathematica script strips off a Mathematica notebook of useless meta data,
cache data, and CellChangeTime. It also adds some flags to prevent the addition
of such data to the notebook.

This is currently under development and being tested only on Linux.

Usage
-----
    $ ./strip.m {filename}

This will generate `output.nb` in the working directory.

