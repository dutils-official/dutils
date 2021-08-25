/*binom.d by Ruby The Roobster*/
/* Version 0.2.5 Release*/
/*Last Updated: 08/06/2021*/
/*Module for handling binomials in the D Progrlamming Languge 2.0*/

/*    This file is part of dutils.

    dutils is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    dutils is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with dutils.  If not, see <https://www.gnu.org/licenses/>.*/

module dutils.binom;

public enum unknown { no = 0, yes = 1};

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

		X result() @property	{
			return this.sum_of_outvals;
		}

		X[] seperatedvals() @property	{
			return this.outvals.dup;
		}

		uint[] coefficients()	@property	{
			return this.coefficiants.dup;
		}

		X xval() @property	{
			return this.x;
		}

		X yval() @property	{
			return this.y;
		}

		uint nval() @property	{
			return this.n;
		}	
}

public uint factorial(uint f)	{ //Bug Free
	if(f == 0 || f == 1)
		return 1;
	for(int x = f-1; x > 0; x--)	{
		f = f * x;
	}
	return f;
}

public class InBinom(X) if(is(X : real))	{	//Class for the binomials(input)
	private:
		X x;
		X y;
		uint n;
		unknown xunknown;
		unknown yunknown;
		unknown nunknown;
	public:
		this(X x, X y, uint n, unknown xunknown, unknown yunknown, unknown nunknown)	{
			this.x = x;
			this.y = y;
			this.n = n;
			if(xunknown == unknown.yes || yunknown == unknown.yes)	{
				throw new Exception("Unkown variables are not implemented yet.");
			}
			this.xunknown = xunknown;
			this.yunknown = yunknown;
			this.nunknown = nunknown;
		}

		OutBinom!(typeof(this.x)) BinomEqu()	{ //Implements the Binomial Theorem
			assert(xunknown == unknown.no && yunknown == unknown.no && nunknown == unknown.no); //Replace by exception
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
