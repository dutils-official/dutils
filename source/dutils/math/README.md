# dutils:math
The dutils math library.

## Syntax

### Function Syntax

- All functions are of the form (Params)(Return), where Params is a comma separated list of the function input types, while Return is the type that the function outputs.

- The only valid type as of this writing is Number, with the operators +,-,/,*,and ^^ (which is unimplemented).

- No whitespace (I'm too lazy to make this possible kek).

- To reference the first parameter, you would use x1, the second, x2, and so on and so forth.

## Changelog for dutils v0.2.0

### NEW

-  Created dutils.math.core, dutils.math.def, and dutils.math.number.

-  dutils.math.def contains the definitions for the template mathematical type:  Mtype, and for the wrappers for the function and operator lists.

-  dutils.math.number contains the definition of the Number type, which is currently incomplete and undocumented.
   The Number type currently supports four operations: +, -, *, and /.

-  dutils.math.core currently only supports registering and validating a function.

### REMOVED

- Any prexisting math library code due to it sucking.

## Build Instructions

### Building from the repository (<repo_directory> is a placeholder for whatever directory the repository is copied to):

Requirements: dub and git

    git clone https://RubyTheRoobster/dutils.git <repo_directory>
    cd <repo_directory>

For a static lib build:

    dub build dutils:math --config=standard --build-mode=allAtOnce

For a shared lib build (requires ldc2):

    dub build dutils:math --compiler=ldc2 --config=shared --build-mode=allAtOnce

### Building just using dub

    dub build dutils:math