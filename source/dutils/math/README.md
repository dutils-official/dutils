# dutils:math

The dutils math library.

## Function Syntax

- The func parameter of ExecuteFunction shall be in the following form: name(parameter_types)(return_type)

- All operands shall be referred to by the function as xn, where n is the nth argument

- There is to be no whitespace

- Parentheses are allowed, but must be closed.  There is no order of operations.

## Changelog for dutils v0.2.0

### NEW

-  Created dutils.math.core, dutils.math.def, and dutils.math.number.

-  dutils.math.def contains the definitions for the template mathematical type:  Mtype, and for the wrappers for the function and operator lists.

-  dutils.math.number contains the definition of the Number type, which is currently incomplete.
   The Number type currently supports four operations: +, -, *, and /.

-  dutils.math.core supports registering, validating, and executing a function.

### REMOVED

- Any prexisting math library code due to it sucking.

## Build Instructions

For a static lib build:

    dub build dutils:math --config=standard --build-mode=allAtOnce

For a shared lib build (requires ldc2):

    dub build dutils:math --compiler=ldc2 --config=shared --build-mode=allAtOnce
