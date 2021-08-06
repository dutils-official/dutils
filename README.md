# dutils
DOCUMENTATION FOR DUTILS

dutils.binom:
  fucntions:
    uint factorial(uint f):
      Calculates the factorial of an unsigned integer f and returns it.
  enums:
    enum unknown { no = 0, yes = 1}:
      Represents if something is an unknown or not.
  classes:
    OutBinom(X) if(is(X : real)):
      Class for the output of functions involving binomials.
      OutBinom.this(const uint[] coefficiant, const X[] outvals):
        The orginal constructor for OutBinom. Used when solving using the binomial theorem.
      OutBinom.this(const uint[] coefficiant, const X[] outvals, const X x, const X y, const uint n):
        A more complete constructor for the class(currently not used by the library.)
      OutBinom.result() @property:
        Returns the sum of all the members of outvals as a type X.
      OutBinom.seperatedvals() @property
        Returns the elements of OutBinom.outvals as an array.
      
