# dutils
A collection of(hopefully)useful modules in the D2 Programming Language.

## Changelog for dutils v0.2.0

### NEW

#### dutils.math

-  Created dutils.math.core, dutils.math.def, and dutils.math.number.

-  dutils.math.def contains the definitions for the template mathematical type:  Mtype, and for the wrappers for the function and operator lists.

-  dutils.math.number contains the definition of the Number type, which is currently incomplete and undocumented.
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