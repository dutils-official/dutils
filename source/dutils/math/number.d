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
/** Copyright: 2022, Ruby The Roobster*/
/**Author: Ruby The Roobster, <rubytheroobster@yandex.com>*/
/**Date: August 5, 2021*/
/** License:  GPL-3.0**/

///Module for representing numbers.
module dutils.math.number;

version(DLL)
{
    export:
}

version(Standard)
{
    public:
}

public import dutils.math.core;
public import std.bigint;

class Number : Mtype!NumberContainer
{
    this(NumberContainer num)
    {
        this.contained = val;
    }

    override dstring toDstring() const @property pure @safe
    {
        return this.contained.toDstring;
    }

    override void fromDstring(dstring from) pure @safe
    {
        this.contained.fromDstring(from);
    }

    bool applyOp(W)(dstring op, Mtype!W rhs) pure @safe
    in
    {
        assert(is(W == NumberContainer));
        assert((op == "+"d) ^ (op == "-"d) ^ (op == "*"d) ^ (op == "/"d) ^ (op == "^^"d));
    }
    do
    {
        mixin("this.contained " ~ op ~ "= rhs.contained;");
        return true; //We assume that the contract hasn't been violated.
    }
}
struct NumberContainer
{
    this(BigInt val, BigInt ival = 0, long pow10 = 0, ulong precision = 18) pure @safe nothrow @nogc
    {
        this.val = val;
        this.pow10 = pow10;
        this.ival = ival;
        this.precision = precision;
    }
    
    dstring toDstring() const @property pure @safe
    {
        return ""d; //Placeholder
    }

    void fromDstring(dstring from) pure @safe
    {
        //Placeholder
    }

    void opOpAssign(string op)(NumberContainer rhs) pure @safe
    {
        import std.algorithm : max;
        static if(op == "/")
        {
            //Because BigInt is strictly an integer type, it is easier to code A/B as A*1/B, because the * operator is a piece of cake, and 1 over a BigInt is easier than an arbitrary BigInt
            //over another arbitrary BigInt
            immutable BigInt den = rhs.val ^^ 2 + rhs.ival ^^ 2;
            NumberContainer store = NumberContainer(cast(BigInt)0);
            auto istore = NumberContainer(cast(BigInt)0, cast(BigInt)0);
            long count = 0;
            ubyte count2 = 9;
            bool sign = (rhs.ival < 0); //Fix the infinite loop that occurs for negative values of rhs.ival.
            if(sign)
                rhs.ival *= -1;
            for(ulong i = 0; i < precision; ++i) //Real part
            {
                if(rhs.val == BigInt(0))
                    break;
                //Play around with the multiplier so the denominator actually fits in the numerator.
                while(den > (BigInt(10) ^^ count) * rhs.val)
                {
                    ++count;
                }
                //Remove excess.
                while(den < (BigInt(10) ^^ (count - 1L) * rhs.val))
                {
                    --count;
                }

                for(; count2 * den > (BigInt(10) ^^ count) * rhs.val; --count2)
                {
                        if(count2 < -9) //Remember, negative numbers exist too!
                            throw new Exception("ERROR: Division by 0");
                }

                rhs.val *= (BigInt(10) ^^ count); //`rhs` is a copy, so this isn't an issue.
                rhs.val -= count2 * den; //Continue performing long division.
                store.val *= 10;
                store.val += count2;
                store.pow10 -= count;

                count = 0;
                count2 = 9;
            }


            for(ulong i = 0; i < precision; ++i) //Imaginary part.
            {
                if(rhs.ival == BigInt(0))
                    break;
                while(den > (BigInt(10) ^^ count) * rhs.ival)
                {
                    ++count;
                }
                //Remove excess.
                while(den < (BigInt(10) ^^ (count - 1L) * rhs.ival))
                {
                    --count;
                }

                for(; count2 * den > (BigInt(10) ^^ count) * rhs.ival; --count2)
                {
                        if(count2 < -9) //Remember, negative numbers exist too!
                            throw new Exception("ERROR: Division by 0");
                }

                rhs.ival *= (BigInt(10) ^^ count); //`rhs` is a copy, so this isn't an issue.
                rhs.ival -= count2 * den; //Continue performing long division.
                istore.ival *= 10;
                istore.ival += count2;
                istore.pow10 -= count;

                count = 0;
                count2 = 9;
            }
            import std.algorithm : min, max;
            if(!sign)
                 istore.ival *= -1;
            store += istore;
            this *= store;
        }
        else static if(op == "^^")
        {
            //Oy Vey:  I ain't implementing this until function execution and exponential functions exist..
        }
        else static if(op == "*")
        {
            auto temp = this.val;
            this.val *= rhs.val;
            this.val -= (this.ival * rhs.ival);
            this.ival = (this.ival * rhs.val);
            this.pow10 += rhs.pow10;
            this.ival += (temp * rhs.ival);
        }
        else
        {
            if(this.pow10 > rhs.pow10)
            {
                this.val *= BigInt(10) ^^ (this.pow10 - rhs.pow10);
                this.ival *= BigInt(10) ^^ (this.pow10 - rhs.pow10);
            }
            else if(rhs.pow10 > this.pow10)
            {
                rhs.val *= BigInt(10) ^^ (rhs.pow10 - this.pow10);
                rhs.ival *= BigInt(10) ^^ (rhs.pow10 - this.pow10);
            }
            this.pow10 = rhs.pow10;
            mixin("this.val " ~ op ~ "= rhs.val;");
            mixin("this.ival " ~ op ~ "= rhs.ival;");
        }
    }

    NumberContainer opBinary(string op)(NumberContainer rhs) pure @safe
    {
        NumberContainer ret = this;
        mixin("ret " ~ op ~ " rhs;");
        return ret;
    }
    package:
        BigInt val;
        BigInt ival;
        long pow10;
        ulong precision;
}

@safe unittest {
    BigInt a = 1;
    BigInt b = -1;
    long c = 0;
    NumberContainer e = NumberContainer(a,b,c);
    a = 2;
    NumberContainer f = NumberContainer(a,b,c);
    e /= f;
    assert(((e).val == 6 && (e).pow10 == -1) && e.ival == -2);
    
}
