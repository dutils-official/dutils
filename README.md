# dutils
A collection of(hopefully)useful modules in the D2 Programming Language.
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
