# dutils

A collection of (hopefully) useful modules in the D2 Programming Language.

This project was initially supposed to be a collection of whatever modules I decided to write for the 
D programming language (not unlike Arsd), but it had no direction, and I soon forgot about it.
After months, I picked it up again, and decided to make a game engine, mainly centered around
a robust mathematics library (which is currently all there is) and modularity: i.e. one can
write an additional module extending upon the base framework with little to no effort.

## What's With the Version Number?

I am an absolute monkey, and started it at v0.1.0 for some reason.  Don't ask, I do not remember at this point.

## Changelog for dutils v0.2.0

### NEW

#### dutils.math

-  Created dutils.math.core, dutils.math.def, and dutils.math.number.

-  dutils.math.def contains the definitions for the template mathematical type:  Mtype, and for the wrappers for the function and operator lists.

-  dutils.math.number contains the definition of the Number type, which is currently incomplete.
   The Number type currently supports four operations: +, -, *, and /, and the functions toDstring and fromDstring.
   The ^^ exponentiation operation will be done later, as it requires logarithms and arguments. 

-  dutils.math.core supports registering, validating, and executing a function.

### REMOVED

- The entire library is getting a revamp, so I removed the existing iteration of the Math Library.
  Soon the rest of the library will be replaced, but until then, it wil remain.

## Build Instructions

For a static lib build:

    dub build --config=standard --build-mode=allAtOnce

For a shared lib build (requires LDC or GDC):

    dub build --compiler=ldc2 --config=shared --build-mode=allAtOnce