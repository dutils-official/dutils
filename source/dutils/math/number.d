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
/** Copyright: 2022-2023, Ruby The Roobster*/
/**Author: Ruby The Roobster, <michaeleverestc79@gmail.com>*/
/**Date: January 16, 2023*/
/** License:  GPL-3.0*/

/// Module for representing numbers.
module dutils.math.number;

version(DLL)
{
    export:
}

version(Standard)
{
    public:
}

/// Core dutils math library.
public import dutils.math.core;
/// BigInt is a necessary type for our usage.
public import std.bigint;

/// Class to represent Numbers in dutils.
class Number : Mtype!NumberContainer
{
    /*****************************************************************
     * Constructs a Number.
     *
     * Params:
     *     num =
     *         The value to contain within the Number.
     */
    this(in NumberContainer num = NumberContainer(BigInt(0), BigInt(0), 0)) pure @safe nothrow
    {
        super(num);
    }

    /************************************************
     * Constructs a Number using precision only.
     *
     * Params:
     *     precision =
     *          The precision of the NumberContainer.
     */
     this(ulong precision) pure @safe nothrow
     {
        super(precision);
     }

    /***********************************************
     * Represents a Number as a dstring.
     *
     * Returns:
     *     The dstring representation of the Number.
     */
    override dstring toDstring() const @property pure @safe
    {
        import std.format;
        char[] temp = "".dup;
        pragma(inline, true) void inFunc(in size_t i, in BigInt val) pure @safe
        {
            char[] temp2 = format("%s", val).dup;
            if(this.contained.pow10 > 0)
            {
                temp ~= temp2;
                temp.length += this.contained.pow10;
                temp[$-this.contained.pow10 .. $] = '0';
            }
            else if(this.contained.pow10 < 0)
            {
                if(val < BigInt(0))
                {
                    temp2[0 .. $-1] = temp2[1 .. $].dup;
                    --temp2.length;
                }
                temp ~= temp2;
                if(-this.contained.pow10 > temp2.length)
                {
                    temp.length -= (this.contained.pow10);
                    temp[i] = '.';
                    temp[i+1 .. i+1-(this.contained.pow10+temp2.length)] = '0';
                    temp[i+1-(this.contained.pow10 + temp2.length) .. $] = temp2.dup;
                }
                else if(temp2.length == -this.contained.pow10)
                {
                    temp2 = temp[i-1-this.contained.pow10 .. $].dup;
                    temp[i-1-this.contained.pow10] = '.';
                    ++temp.length;
                    temp[i-this.contained.pow10 .. $] = temp2.dup;
                }
                else
                {
                    ++temp.length;
                    temp[i-this.contained.pow10 .. $] = temp[i .. $-1].dup;
                    temp[i-this.contained.pow10] = '.';
                }
            }
            else
            {
                temp ~= temp2;
            }
        }
        inFunc(0, this.contained.val);
        if(this.contained.ival < 0)
            temp ~= '-';
        else
            temp ~= '+';
        inFunc(temp.length, this.contained.ival);
        temp ~= 'i';
        dchar[] temp2;
        foreach(c; temp)
        {
            ++temp2.length;
            temp2[$-1] = d(c);
        }
        return temp2.idup;
    }

    /***********************************
     * Serializes a dstring to a Number.
     *
     * Params:
     *     from =
     *         The dstring to serialize.
     */
    override void fromDstring(dstring from) pure @safe
    {
        dchar[] val;
        dchar[] ival;
        size_t i;
        do
        {
            val ~= from[i];
            ++i;
        }
        while(i == 0 || (from[i] != d('+') && from[i] != d('-')));
        do
        {
            ival ~= from[i];
            ++i;
        }
        while(i < from.length);

        i = 0;
        long dec = -1;
        long z = 0;
        size_t firstz = 0;
        size_t[] zi;
        import std.conv : to;
        bool neg = false;
        if(val[0] == d('-'))
        {
            neg = true;
            val[0 .. $-1] = val[1 .. $].dup;
            --val.length;
        }
        pragma(inline, true) void inFunc(in dchar[] val, ref BigInt rval)
        {
            rval = BigInt(0);
            do
            {
                if(val[i] == d('.'))
                {
                    dec = i;
                    ++i;
                    continue;
                }

                else if(val[i] == d('0'))
                {
                    if(firstz == 0)
                        firstz = i;
                    zi ~= i;
                    ++i;
                    continue;
                }
                BigInt temp = BigInt(10);
                temp ^^= (val.length-1-i);
                temp *= BigInt(to!ubyte([val[i]]));
                rval = temp;
                ++i;
            }
            while(i < val.length);
            i = 0;

            if(neg)
                rval *= -1;
            neg = false;
        }
        
        inFunc(val, this.contained.val);
        if(dec == -1)
        {
            this.contained.pow10 = zi.length;
            do
            {
                if(zi.length == 0)
                    break;
                ++i;
            }
            while(i < zi.length-1 && zi[i-1] == zi[i] -1);
            this.contained.val /= BigInt(10) ^^ i;
        }
        else if(firstz == 0)
            this.contained.pow10 = -zi.length; 
        else
            this.contained.pow10 = -(val.length-1-dec);
        firstz = 0;
        zi = [];
        z = 0;
        i = 0;
        dec = 0;
        --ival.length; //The last character of ival is d('i'), which is a non integer.
        if(ival[0] == d('-'))
            neg = true;
        ival[0 .. $-1] = ival[1 .. $].dup;
        --ival.length;
        inFunc(ival, this.contained.ival);
    }

    /*************************************************
     * Applies an operator to a Number given the rhs.
     *
     * Params:
     *     op =
     *         The operator to apply.
     *     rhs =
     *         The right hand side of the expression.
     * Returns:
     *     Whether the operation was succesful or not.
     */
    bool applyOp(W)(in dstring op, in Mtype!W rhs) pure @safe
    in
    {
        import std.conv : to;
        assert(is(W == NumberContainer));
        assert((op == "+"d) ^ (op == "-"d) ^ (op == "*"d) ^ (op == "/"d) ^ (op == "^^"d), to!string(op));
    }
    do
    {
        Switch: final switch(op)
        {
            static foreach(o; ["+"d, "-"d, "*"d, "/"d, "^^"d])
            {
                case o:
                    mixin("this.contained "d ~ o ~ "= rhs.contained;"d);
                    break Switch;
            }
        }
        return true; //We assume that the contract hasn't been violated.
    }

    /*************************************************
     * The result of applying an operator to a Number.
     *
     * Params:
     *     op =
     *         The operator to apply.
     *     rhs =
     *         THe right hand side of the expression.
     * Returns:
     *     The result of the expression.
     */
    Number applyOpResult(W)(dstring op, Mtype!W rhs) pure @safe
    {
        Number temp = new Number();
        temp.val = this.val;
        temp.applyOp!W(op, rhs);
        return new Number(temp.val);
    }

    /*****************************************
     * Detrmine if two Numbers are equal.
     *
     * Params:
     *     rhs =
     *        The Number to compare `this` to.
     * Returns:
     *     Whether `this` and rhs are equal.
     */
    bool opEquals(in Number rhs) pure const @safe nothrow @nogc
    {
        return (this.contained == rhs.contained);
    }
}

///
pure @safe unittest {
    BigInt a = 1;
    immutable BigInt b = -1;
    immutable long c = 0;
    Number e = new Number(NumberContainer(a,b,c));
    a = 2;
    Number f = new Number(NumberContainer(a,b,c));
    e.applyOp("/", f);
    assert(e.val == NumberContainer(BigInt(6), BigInt(-2), -1L));
    assert(e.toDstring == ".6-.2i"d);
    f = new Number(NumberContainer(BigInt(6), BigInt(0), 1L));
    assert(f.toDstring == "60+00i"d);
    auto g = f.toDstring;
    f.fromDstring(g);
    assert(f.toDstring == g, cast(char[])f.toDstring.dup);
    f = new Number(NumberContainer(BigInt(6), BigInt(0), -2L));
    assert(f.toDstring == ".06+.00i"d, cast(char[])f.toDstring.dup);
    g = f.toDstring;
    f.fromDstring(g);
    assert(g == f.toDstring);
    f = new Number(NumberContainer(BigInt(3), BigInt(6), -23L));
    g = f.toDstring;
    f.fromDstring(g);
    assert(g == f.toDstring);
    f = new Number(NumberContainer(BigInt(6), BigInt(0), 0L));
    assert(f.toDstring == "6+0i"d);
    f = new Number(NumberContainer(BigInt(60), BigInt(0), -1L));
    assert(f.toDstring == "6.0+.0i"d, cast(char[])f.toDstring.dup);
}

/// Type that is contained by Number.
struct NumberContainer
{
    /**********************************************************************************
     * Constructs a NumberContainer.
     *
     * Params:
     *     val =
     *         The real part of the NumberContainer, expressed as a BigInt.
     *     ival =
     *         The imaginary part of the NumberContainer, expressed as a BigInt.
     *     pow10 =
     *         The power of 10 to multiply both parts by.
     *     precision =
     *         The digits of precision to use in divison and exponentiation operations.
     */
    this(BigInt val, BigInt ival = 0, long pow10 = 0, ulong precision = 18) pure @safe nothrow @nogc
    {
        this.val = val;
        this.pow10 = pow10;
        this.ival = ival;
        this.precision = precision;
    }

    /*******************************************************
     * Assigns a NumberContainer to another NumberContainer.
     *
     * Params:
     *     rhs =
     *         The NumberContainer to assign.
     */
    void opAssign(in NumberContainer rhs) pure @safe nothrow @nogc
    {
        this.pow10 = rhs.pow10;
        this.val = rhs.val;
        this.ival = rhs.ival;
        this.precision = rhs.precision;
    }

    /*************************************************
     * Overloading of the binary assignment operators.
     *
     * Params:
     *     rhs =
     *         The right hand side of the expression.
     */
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
            immutable bool sign = (rhs.ival < 0); //Fix the infinite loop that occurs for negative values of rhs.ival.
            if(sign)
                rhs.ival *= -1;
            for(ulong i = 0; i < this.precision; ++i) //Real part
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
            //Oy Vey:  I ain't implementing this until Riemann Sums and oprators exist.
        }
        else static if(op == "*")
        {
            immutable temp = this.val;
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

    /*******************************************************
     * Overloading of the binary operators.
     *
     * Params:
     *     rhs =
     *         The right hand side of the expression.
     * Returns:
     *     The result of the expression.
     */
    NumberContainer opBinary(string op)(NumberContainer rhs) pure @safe
    {
        NumberContainer ret = this;
        mixin("ret " ~ op ~ " rhs;");
        return ret;
    }

    /*************************************
     * Determine if two Numbers are equal.
     *
     * Params:
     *     rhs =
     *         The Number to compare with.
     * Returns:
     *     Whether this is equal to rhs.
     */
    bool opEquals(in NumberContainer rhs) pure @safe nothrow const @nogc
    {
        return ((this.val == rhs.val) && (this.ival == rhs.ival))
        && ((this.pow10 == rhs.pow10) && (this.precision == rhs.precision));
    }
    package:
        BigInt val;
        BigInt ival;
        static if(is(size_t == ulong))
            long pow10;
        else static if(is(size_t == uint))
            int pow10;
        ulong precision;
}
