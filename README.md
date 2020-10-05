
nb-strip - Mathematica notebook cleaner
=======================================

This Mathematica script strips off a Mathematica notebook of useless meta data,
cache data, and CellChangeTime. It also adds some flags to prevent the addition
of such data to the notebook.

Tested only on Linux.

Usage
-----
    $ ./strip.m {filename}

This will generate `output.nb` in the working directory.

Options
-------

 * `-h`: Print help message.

 * `-O`: Do *NOT* strip "Output" cells.

 * `-o`: The name of output file. By default, this value is generated from input
   file name. Examples:

        *.nb -> *.strip.nb
        *.cdf -> *.strip.cdf

