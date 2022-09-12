# dutils:math
The dutils math library.

## Function Syntax

- No whitespace, unless right after an operatorand before a function, in which case a single space (no more, no less) is required.

- The func parameter of ExecuteFunction shall be in the following form: name(parameter_types)(return_type)

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