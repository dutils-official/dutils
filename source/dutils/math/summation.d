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
/**Date: March 6, 2023*/
/** License:  GPL-3.0*/

/** Implements Summation Operator*/
module dutils.math.summation;

version(DLL)
{
    export:
}
else
{
    public:
}


/// TODO:  ADD RIEMANN SUMS WHEN DONE

/// Definitions file
import dutils.math.def;

private import dutils.math.core;
private import dutils.math.number;

/*********************************************************
 * Implements Summation
 * TODO: FIX DOCS
 * Params:
 *     op =
 *         The arguments to be passed in.  These are:
 *         A registered function, with its input
 *         specified n (the index), and whatever
 *         parameters from the function the operator was
 *         called in; The intial value of the index (real);
 *         and the maximum value of the index (real);
 *         the types of the paramaters of the function,
 *         separated by commas.
 *
 * Returns:
 *     A dstring containing the serialized value of the
 *     sum of the function about the index.
 */
dstring summation(T ...)(dstring[] op) @safe
{
    dstring ret;
    dstring func; // Store the function here.
    assert(op.length == 3);
    Number index = new Number(NumberContainer(BigInt(0), BigInt(0), 0, precision));
    dstring temp = ""d;
    for(size_t i = 0; i < op[1].length; ++i) // Get the lower value of index first, it's easiest.
        temp ~= op[1][i];
    index.fromDstring(temp);

    temp = ""d;
    dstring[] paramTypes;
    dstring[] paramValues;
    size_t[][dstring] typeIndices;
        
    Tuple!T args;
    size_t i;
    for(i = 0; op[0][i] != d('('); ++i) // Get function name.
        temp ~= op[0][i];

    dstring temp2;
    size_t n_index;
    size_t k = 0;
    ++i;
    for(; op[0][i] != d(')'); ++i) // Get the values of the function parameters.
    {
        if(op[0][i] == d(','))
        {
            if(temp2 != "n")
                paramValues ~= temp2;
            else
            {
                n_index = k;
                paramValues ~= ""d;
            }
            temp2 = ""d;
            ++k;
            continue;
        }
        temp2 ~= op[0][i];
    }

    paramValues ~= temp2; // This last is cut off in the loop.
    temp2 = ""d;
    i += 2;
    temp ~= "("d;
    size_t j = 0;
    for(; op[0][i] != d(')'); ++i) // Get the function parameter types
    {
        if(op[0][i] == d(','))
        {
            if(j != n_index)
            {
                paramTypes ~= temp2;
                typeIndices[temp2] ~= j;
            }
            else
            {
                paramTypes ~= "Number"d;
                typeIndices["Number"d] ~= j;
            }
            temp ~= d(',');
            ++j;
            temp2 = ""d;
            continue;
        }
        temp2 ~= op[0][i];
    }
    paramTypes ~= temp2;
    temp ~= ")("d;
    typeIndices[temp2] ~= j;
    ++j;
    i +=2;
    for(; op[0][i] != d(')'); ++i)
        ret ~= op[0][i];
    temp ~= ")"d;
    temp2 = ""d;

    Number upperindex = new Number(NumberContainer(BigInt(0), BigInt(0), 0, precision));
    for( i = 0; i < op[2].length; ++i) // Get the upper index
        temp2 ~= op[2][i];
    upperindex.fromDstring(temp2);
    auto one = new Number(NumberContainer(BigInt(1), BigInt(0), 0, precision));

    // Set up for repeated function calls (intialize temporary variables)
    size_t indo = 0;
    
    static foreach(type; typel)
    {
        if(type in typeIndices)
        {
            foreach(ind; typeIndices[type])
            {
                mixin("args[ind] = new " ~ type ~ "();");
                if(paramValues[ind] != ""d)
                    mixin("args[ind].fromDstring(paramValues[ind]);");
                else
                {
                    mixin("args[ind] = new " ~ type ~ "(index.val);"); // n
                    indo = ind;
                }
            }
        }
    }

    // return type
    static foreach(type; typel)
    {
        mixin(type ~ " ret" ~ type ~ " = new " ~ type ~ "();");
    }

    coco: for(; index.opCmp!"<="(upperindex); args[indo].applyOp("+", one)) // Main loop
    {
        static foreach(type; typel)
        {
            if(type == ret)
            {
                mixin("ret" ~ type ~ " = executeFunction(args);");
                continue coco;
            }
        }
    }

    static foreach(type; typel)
    {
        if(type == ret)
        {
            mixin("return ret" ~ type ~ ".toDstring;");
        }
    }
    assert(0);
}

/// The precision to be used while doing the summation.
private size_t precision = 18;

/***************************
 * Sets the precision.
 *
 * Params:
 *     prec =
 *        The new precision.
 */
void setPrecision(in size_t prec) @safe nothrow @nogc
{
    precision = prec;
}

