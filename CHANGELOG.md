# Changelog for dutils v0.2.0 as of August 17, 2022

## NEW

### dutils.math

-  Created dutils.math.core, dutils.math.def, and dutils.math.number.

-  dutils.math.def contains the definitions for the template mathematical type:  Mtype, and for the wrappers for the function and operator lists.

-  dutils.math.number contains the definition of the Number type, which is currently incomplete and undocumented.
   The Number type currently supports four operations: +, -, *, and /, and the function toDstring.

-  dutils.math.core currently only supports registering and validating a function.

## REMOVED

- The entire library is getting a revamp, so I removed everything else.

# Changelog for dutils v0.1.4
### dutils.math

A math library for dutils.  Capable of exectuting dstrings as user defined functions, provided that these
are functions that map C (the space of all complex numbers) to C.

The only operations supported are +, -, /, *, and ^^, with ^^ being exponentiation.

The whole math syntax is located in 'MATH SYNTAX.md'.

As of this version, all of the math operations are located in dutils.math.core.

## Add shared configuration

There is now a shared configuration that outputs a shared library as supposed to a dynamic one.

This configuration doesn't build with dmd 2.099.1 (and probably any dmd) due to spewing out a million
linker errors every single time I try.  It does build with ldc 1.29.0, and I have no idea about GDC.

## Build Instructions

### Building from the repository (<repo_directory> is a placeholder for whatever directory the repository is copied to):

Requirements: dub 1.28.0 (should work on other dub, but not tested), and git

    git clone https://RubyTheRoobster/dutils.git <repo_directory>
    cd <repo_directory>

For a static lib build:

    dub build --config=standard --build-mode=allAtOnce

For a shared lib build (requires ldc 1.29.0, untested on other ldc):

    dub build --compiler=ldc2 --config=shared --build-mode=allAtOnce

### Building just using dub

    dub build dutils

# Changelog for dutils v0.1.3
## transform.d
A library that contains all basic transofrmation functions(move, scale, and rotate), including a scale function that you can specify the axis to scale on.
## physics.d
Added a frame-specified rotation function and the Plane enumeration.
## skeleton.d
Minor improvements to both Skeleton and Point structs.
### Skeleton struct
Made Skeleton.center the geometric center of the skeleton.
### Point struct
Added many operations, including opBinary, and allowed for these operators to be used with numerical types, not just other Point structs.

# Changelog for dutils v0.1.2
## physics.d
An all-new physics simple physics library has been integrated into dutils with this release.  Probably still has much to be desired.
## Documentation Reform
I have revised how I put the documentation, in hopes that it is actually readable when people are viewing the package.
## Addition of Changelogs & README.md Reform
There will now be a file called CHANGELOG.md, which starting with the current release, will serve as a changelog.  In addition, the most recent changelog will be posted on the README.md file.
