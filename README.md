# dutils
A collection of(hopefully)useful modules in the D2 Programming Language.

## Changelog for dutils v0.1.4:

### dutils.math

A math library for dutils.  Capable of exectuting dstrings as user defined functions, provided that these
are functions that map C (the space of all complex numbers) to C.

The only operations supported are +, -, /, *, and ^^, with ^^ being exponentiation.


As of this version, all of the math operations are located in dutils.math.core.

## Add shared configuration

There is now a shared configuration that outputs a shared library as supposed to a dynamic one.

This configuration doesn't build with dmd due to spewing out a million
linker errors every single time I try.  It does build with ldc2, and I have no idea about GDC.

## Build Instructions

### Building from the repository (<repo_directory> is a placeholder for whatever directory the repository is copied to):

Requirements: dub and git

    git clone https://RubyTheRoobster/dutils.git <repo_directory>
    cd <repo_directory>

For a static lib build:

    dub build --config=standard --build-mode=allAtOnce

For a shared lib build (requires ldc2):

    dub build --compiler=ldc2 --config=shared --build-mode=allAtOnce

### Building just using dub

    dub build dutils