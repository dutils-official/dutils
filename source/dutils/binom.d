/*binom.d by Ruby The Roobster*/
/* Version 0.2.5 Release*/
/*Module for handling binomials in the D Programming Languge 2.0*/
/*This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.*/
/** Copyright: 2021, Ruby The Roobster*/
/**Author: Ruby The Roobster, rubytheroobster@yandex.com*/
/**Date: October 1, 2021*/
/** License:  GPL-3.0**/

module dutils.binom;
///THIS CODE NEEDS WORK.
///Class: Output of member functions of InBinom
//TODO:ADD DLL
//TODO: FIX AND MAKE IT WORK WITH THE MATH LIB
public class OutBinom(X)  if(is(X : real))	{ //Class for the output of functions involving binomials
	private:
	uint[] coefficiants;
	X[] outvals;
	X sum_of_outvals = 0;
	X x = 0;
	X y = 0;
	uint n = 0;
	public:
		this(const uint[] coefficant, const X[] outvals)	{
			this.coefficiants.length = coefficant.length;
			this.outvals.length = outvals.length;
			for(int i = 0; i < coefficant.length; i++)	{
				this.coefficiants[i] = coefficant[i];
			}

			for(int i = 0; i < outvals.length; i++)	{
				this.outvals[i] = outvals[i];
				this.sum_of_outvals += outvals[i];
			}
		}

		this(const uint[] coefficiant, const X[] outvals, const X x, const X y, const uint n)	{
			this.coefficiants.length = coefficiant.length;
			this.outvals.length = outvals.length;
			for(int i = 0; i < coefficiant.length; i++)	{
				this.coefficiants[i] = coefficiant[i];
			}

			for(int i = 0; i < outvals.length; i++)	{
				this.outvals[i] = outvals[i];
				this.sum_of_outvals += outvals[i];
			}

			this.x = x;
			this.y = y;
			this.n = n;
		}
		///The result generated by the binomial theorem.
		pure X result() const @property	@safe nothrow {
			return this.sum_of_outvals;
		}

		  ///All of the values that InBinom.BinomEqu() spews out without summing it all.
		pure X[] seperatedvals() const @property @safe nothrow	{
			return this.outvals.dup;
		}
		
		  ///All of the coefficiants generated by InBionm.BinomEqu() as an array.
		pure nothrow uint[] coefficients() const @property @safe	{
			return this.coefficiants.dup;
		}
		
		  ///Value of OutBinom.x
		pure nothrow X xval() const @property @safe	{
			return this.x;
		}
		
        ///Value of OutBinom.y.
		pure nothrow X yval() const @property @safe	{
			return this.y;
		}
		
		  ///Value of OutBinom.n.
		pure nothrow uint nval() const @property @safe	{
			return this.n;
		}	
}

  /**The factorial of a number.
  Params:
  f = 	is the number that the factorial is being performed on.
  Returns: The factorial of f.*/
public uint factorial(uint f) pure nothrow @safe	{ //Bug Free
	if(f == 0 || f == 1)
		return 1;
	for(int x = f-1; x > 0; x--)	{
		f = f * x;
	}
	return f;
}

  ///Serves as a set up binomial to perform operations on.
public class InBinom(X) if(is(X : real))	{	//Class for the binomials(input)
	private:
		X x;
		X y;
		uint n;
	public:
		this(X x, X y, uint n)	{
			this.x = x;
			this.y = y;
			this.n = n;
		}
		
		  /**Performs the binomial theorem on the object that it is a member of.
		  Params:
		  none
		  Returns: OutBinom!X containing the result of applying the binomial theorem on the object.*/
		OutBinom!X BinomEqu()	{ //Implements the Binomial Theorem
			uint[] coff;
			coff.length = this.n+1;
			X[] outval;
			outval.length = this.n+1;
			for(uint k = 0; k <= this.n;k++)	{
				coff[k] = (factorial(this.n));
				coff[k]  /= (factorial(this.n - k) * factorial(k));
				outval[k] = (coff[k] * ((this.x ^^ (this.n-k)) * (this.y ^^ (k))));
			}

			auto ret = new OutBinom!(typeof(this.x))(coff,outval);
			return ret;
		}
}

