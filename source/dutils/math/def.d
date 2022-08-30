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
/**Date: August 30, 2021*/
/** License:  GPL-3.0**/

///Definitions for dutils.math.core so as to not clog up the whole file.
module dutils.math.def;

version(DLL)
{
    export:
}

version(Standard)
{
    public:
}

///Base class for all math types.
class Mtype(T) if(__traits(hasMember, T, "precision"))
{
    ///Converts the Mtype to a dstring.
    abstract dstring toDstring() const @property pure @safe;
    ///Converts a dstring to an Mtype.
    abstract void fromDstring(dstring from) pure @safe;
    ///Apply an operation to an Mtype.
    abstract bool applyOp(W)(dstring op, Mtype!W rhs) pure  @safe;
    ///Apply an operation from the right side.
    bool applyOpRight(W)(dstring op, ref Mtype!W lhs) pure @safe
    {
        return lhs.applyOp(op, this);
    }
    ///Return the value stored in the Mtype.
    final T val() const pure @safe @property
    {
        return this.contained;
    }
    ///Return the type if the value contained.
    final auto containedType() const pure @safe @property
    {
        return T.stringof;
    }
    ///Precision Constructor
    this(ulong precision) pure @safe nothrow
    {
        this.contained = T();
        this.contained.precision = precision;
    }
    ///Normal Constructor
    this(in T num = T()) pure @safe nothrow
    {
        this.contained = num;
    }
    protected:
        T contained;
}

///Define an Operator as used by dutils.math.
alias Operator = dstring function(dstring[]) @safe;

///Container for the list of all operators.
struct Oplist
{
    Operator opIndex(dstring op) pure @safe const shared
    {
        return this.ops[op];
    }
    auto opBinaryRight(string op)(dstring key) pure @safe const shared if(op == "in" || op == "!in")
    {
        mixin("return key " ~ op ~ " ops;");
    }
    auto keys() @safe
    {
        return this.ops.keys;
    }
    package:
        Operator[dstring] ops;
}

///The list of all operators.
package shared Oplist opList;

///Container for the function list.
struct Funclist
{
    dstring opIndex(dstring func) pure const @safe shared
    {
        return this.funcs[func];
    }
    auto opBinaryRight(string op)(inout(dchar)[] key) pure const @trusted shared if(op == "in" || op == "!in")
    {
        mixin("return cast(dstring)key " ~ op ~ " funcs;");
    }
    auto keys()
    {
        return this.funcs.keys;
    }
    package:
        dstring[dstring] funcs;
}

///The list of all functions.
package shared Funclist funcList;

package import dutils.math.number;

///The list of all types, that has to be kept here and continously updated.
enum dstring[] typel = ["Number"]; //Too bad that complete modular programming is impossible in D.
