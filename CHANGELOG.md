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
