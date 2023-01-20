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
/**Author: Ruby The Roobster, <rubytheroobster@yandex.com>*/
/**Date: January 16, 2023*/
/** License:  GPL-3.0**/

///Core part of the dutils math library.
module dutils.math.core;

public import dutils.math.def;

version(DLL)
{
    mixin("export:");
}

else
{
    mixin("public:");
}

/********************************************************
 * Registers a valid function that doesn't already exist.
 *
 * Params:
 *     name =
 *         The function name.
 *     func =
 *         The function parameters and return type.
 *     def =
 *         The definition of the function.
 *
 * Returns:
 *     Whether the function was registered.
 */
 
bool registerFunction(in dstring name, in dstring func, in dstring def) @safe
{
    auto ret = validateFunction(func, def) && name ~ func !in funcList.funcs;
    if(ret)
        funcList.funcs[name ~ func] = def;
    return ret;
}

///
@safe unittest
{
    dstring func = "(Number)(Number)"d;
    dstring def = "x1"d;
    dstring name = "f"d;
    assert(registerFunction(name, func, def));
    assert(!registerFunction(name, func, def)); //No registering an already-existing function.
}

/**************************************************
 * Removes a function provided that it exists.
 *
 * Params:
 *     name =
 *         The function name.
 *     func =
 *         The function parameters and return type.
 *
 * Returns:
 *     Whether the function exists or not.
 */
bool removeFunction(in dstring name, in dstring func) @safe
{
    if(name ~ func in funcList.funcs)
    {
        funcList.funcs.remove(name ~ func);
        return true;
    }
    return false;
}

///
@safe unittest
{
    dstring func = "(Number,Number)(Number)d";
    dstring def = "x1*x2"d;
    dstring name = "f"d;
    assert(registerFunction(name, func, def)); //Valid, a different function under the same name is a different function in the library's eyes.
    assert(removeFunction(name, func));
    assert(!removeFunction(name, func)); //Cannot remove a non-existent function.
}

/*******************************************
 * Validates a function.
 *
 * Params:
 *     func =
 *        The function name and parameters.
 *     def =
 *          The definition of the function.
 * Returns:
 *     Whether the function is valid or not.
 */
 
bool validateFunction(in dstring func, in dstring def) @trusted
{
    try
    {
        dstring[] params;
        dstring[] returni;
        size_t i = 0;
        getParamsReturns(params, func, i); //Get the function return type.
        dstring returns;
        ++i; //Make sure to get out of the closing parenthesis.
        getParamsReturns(returni, func, i); //Get the parameter types.
        static foreach(type; typel)
        {
            mixin(type ~ "[] " ~ type ~ "ParamList;");
            mixin(type ~ "[] " ~ type ~ "OperandList;");
        }
        returns = returni[0];
        //Make sure that we know the types of of each parameter.
        dstring[] paramTypeList = [];
        dstring returnType = null;
        for(size_t j = 0; j < params.length; j++)
        {
            Switch: final switch(params[j])
            {
                static foreach(type; typel)
                {
                    case type:
                        mixin("++" ~ type ~ "ParamList.length;");
                        ++paramTypeList.length;
                        paramTypeList[j] = type;
                        break Switch;
                }
            }
        }
        //Get the return type.
        for(size_t j = 0; j < 1; j++)
        {
            Switch2: final switch(returns)
            {
                static foreach(type; typel)
                {
                    case type:
                        returnType = type;
                        break Switch2;
                }
            }
        }   
        //This gets scary.
        //Buckle up.
        bool isOperand = false;
        bool isOp = false;
        dstring currOperand;
        dstring currOp;
        dstring prevOp;
        dstring tempNum;
        import std.uni : isNumber;
        i = 0;
        long indentation = 0;
        do
        {
            tempNum = ""d;
            switch(def[i])
            {
                case d('('):
                    ++indentation;
                    ++i;
                    break;
                case d(')'):
                    --indentation;
                    ++i;
                    break;
                case d('x'):
                    if(isOperand && !isOp)
                        return false;
                    prevOp = currOperand.idup;
                    isOperand = true;
                    ++i;
                    if(!def[i].isNumber) //Forced indexing of parameters.
                        return  false;
                    do
                    {
                        tempNum ~= def[i];
                        if(i == def.length-1)
                        {
                            if(def[i].isNumber)
                                break;
                            else
                                --i;
                        }
                        ++i;
                    }
                    while(def[i].isNumber);
                    import std.conv : to;
                    dstring tempType;
                    tempType = paramTypeList[to!size_t(tempNum) - 1];
                    Switch3: final switch(tempType)
                    {
                        static foreach(type; typel)
                        {
                            case type:
                                mixin(type ~ "OperandList ~= new "d ~ type ~ "();"d);
                                currOperand = type;
                                break Switch3;
                        }
                    }
                    //Op verification.
                    if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                    {
                        Switch4: final switch(currOperand)
                        {
                            static foreach(type; typel)
                            {
                                case type:
                                    Switch5: final switch(prevOp)
                                    {
                                        static foreach(type2; typel)
                                        {
                                            case type2:
                                                mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], "
                                                ~ type ~ "OperandList[0], currOp);");
                                                if(!b)
                                                    return false;
                                                break Switch5;
                                        }
                                    }
                                    break Switch4;
                            }
                        }
                    }
                    isOp = false;
                    if(i == def.length - 1)
                    {
                        if(!def[i].isNumber && def[i] != d(')'))
                        {
                            return false;
                        }
                        else if(def[i].isNumber)
                            ++i;
                    }
                    break;
                case d('\\'): //May possibly be even worse than above, as it denotes a special operator. Also ridden with bugs, but I ain't fixin' that until this code is actually used.
                    if(isOperand && !isOp)
                        return false;
                    isOperand = true;
                    dstring opName;
                    prevOp = currOperand.idup;
                    ++i;
                    do
                    {
                        opName ~= def[i];
                        ++i;
                    }
                    while(def[i] != d('('));
                    //Get the  type of the operand as it is needed for later.
                    dstring tempTypeCrap = ""d;
                    do
                    {
                        tempTypeCrap ~= def[i];
                        ++i;
                    }
                    while(def[i] != d(')'));
                    ++i;
                    currOperand = tempTypeCrap;
                    if(def[i] != d('('))
                        return false;
                    dstring[] tempOps = [];
                    ++i;
                    do
                    {
                        ++tempOps.length;
                        do
                        {
                            tempOps[$-1] ~= def[i];
                            ++i;
                        }
                        while(def[i] != d(',') && def[i] != d(')')); //Just in case.
                        if(def[i] == d('(')) //Fix bug involving functions being broken
                        {
                            for(ubyte j = 0; j < 2; j++)
                            {
                                do
                                {
                                    tempOps[$-1] ~= def[i];
                                    ++i;
                                }
                                while(def[i] != d(')'));
                            }
                            tempOps[$-1] ~= d(')');
                            ++i;
                        }
                        if(def[i] != d(',') && def[i] != d(')'))
                            return false;
                    }
                    while(def[i] != d(')'));
                    ++i;
                    if(def[i] != '\\')
                        return false;
                    //Get the types of the parameters referenced by the special operator call.
                    dstring[] tempTypes = [];
                    dstring func2;
                    foreach(tempOp; tempOps)
                    {
                        size_t k = 1;
                        tempNum = ""d;
                    
                        if(tempOp[0] == d('x'))
                        {
                            tempNum ~= d('x');
                            do
                            {
                                tempNum ~= tempOp[k];
                                ++k;
                            }
                            while(tempOp[k] != d('(') && k != tempOp.length - 1);
                            if(k == tempOp.length -1)
                                k = 1;
                            else
                                goto Func;
                        }
                        tempNum = "";
                        func2 = "("d;
                        do
                        {
                            tempNum ~= tempOp[k];
                            if(!tempOp[k].isNumber)
                                return false;
                            k++;
                        }
                        while(k != tempOp.length);
                        ++tempTypes.length;
                        import std.conv : to;
                        tempTypes[$-1] = paramTypeList[to!size_t(tempNum) - 1];
                        continue;
                    
                        Func:
                        k = 1;
                        //Function type header.
                        ++tempTypes.length;
                        tempTypes[$-1] = ""d;
                        //Get the function's return type (very easy, considering how it is specified).
                        do
                        {
                            tempNum ~= tempOp[k];
                            ++k;
                        }
                        while(tempOp[k] != d(')'));
                        ++k;
                        tempTypes[$-1] = tempNum;
                        func2 ~= tempNum;
                        func2 ~= ")("d;
                        tempNum = ""d;

                        //Get the types of the function's parameters.
                        dstring[] tempTypes2 = [];
                        do
                        {
                            ++k;
                            ++tempTypes2.length;
                            do
                            {
                                tempTypes2[$-1] ~= tempOp[k];
                                ++k;
                            }
                            while(tempOp[k] != d(',') && tempOp[k] != d(')'));
                        }
                        while(tempOp[k] != d(')'));

                        foreach(type; tempTypes2)
                        {
                            size_t l = 1;
                            if(type[0] != d('x'))
                                return false;
                            do
                            {
                                tempNum ~= type[l];
                                if(!type[l].isNumber)
                                    return false;
                                ++l;
                            }
                            while(l < type.length);

                            func2 ~= paramTypeList[to!size_t(tempNum) - 1];
                            func2 ~= d(',');
                        }

                        --func2.length;
                        func2 ~= d(')');
                        if(func2 !in funcList)
                            return false;
                    }
                    //Verify that the types match.
                    opName ~= "("d;
                    foreach(type; tempTypes)
                    {
                        opName ~= type;
                        opName ~= ","d;
                    }
                    --opName.length;
                    opName ~= ")"d;
                    if(opName !in opList)
                        return false;
                    currOperand = opName;
                    if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                    {
                        Switch6: final switch(currOperand)
                        {
                            static foreach(type; typel)
                            {
                                case type:
                                    Switch7: final switch(prevOp)
                                    {
                                        static foreach(type2; typel)
                                        {
                                            case type2:
                                                mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], "
                                                ~ type ~ "OperandList[0], currOp);");
                                                if(!b)
                                                    return false;
                                                break Switch7;
                                        }
                                    }
                                    break Switch6;
                            }
                        }
                        ++i;
                    }
                    isOp = false;
                    break;
                default: // Operators and functions
                    if(isOp)
                        return false;
                    isOp = true;
                    isOperand = false;
                    dchar[] tempstr = [];
                    do
                    {
                        tempstr ~= def[i];
                        if(((def[i] != d('x')) && (def[i] != d('\\'))) && (def[i] != d('(') && def[i] != d(' ')))
                             ++i;
                    }
                    while((def[i] != d('x') && def[i] != d('\\')) && (def[i] != d('(') && def[i] != d(' ')));
                    
                    /+if(def[i] != d('(')) // Operators+/
                        currOp = tempstr.idup;
                    /+else //  Oh shit oh fuck a function (THIS CODE DOESN'T WROK AND WILL BE FIXED LATER)
                    {
                        // We need to get the types of its arguments
                        tempstr = tempstr[0 .. $-1].dup;
                        dchar[] tempargs = [];
                        ++i;
                        do
                        {
                            tempargs ~= def[i];
                            ++i;
                        }
                        while(def[i] != d(')'));

                        import std.algorithm;
                        auto indexes = tempargs.splitter(d(','));
                        foreach(ref index; indexes)
                            index = index[1 .. $].dup;

                        size_t[] indices = [];
                        import std.conv;
                        foreach(index; indexes)
                            indices ~= index.to!size_t;

                        dstring[] temptypes;
                        foreach(indice; indices)
                            temptypes ~= paramTypeList[indice];

                            
                    }+/
            }
        }
        while(i < def.length);
        if((isOp || !isOperand) || indentation != 0) //If there are no other syntax errors, ensure the following.
        {
            return false;
        }
        return true;
    }
    catch(Exception e)
    {
        return false;
    }
}

///
@safe unittest
{
    /********************************************
    * List of stuff that is invalid but crashes:
    *
    *     Whitespace
    *     Preceding Operators
    *     Invalid Operators and Characters
    */ 
    dstring func = "(Number,Number)(Number)"d;
    dstring def = "x1*x2"d;
    assert(validateFunction(func, def));
    func = "(Number,Number,Number)(Number)"d;
    def = "x1*x2+x3"d;
    assert(validateFunction(func, def));
    def = "(x1"d;
    assert(!validateFunction(func, def));
    def = "(x1)"d;
    assert(validateFunction(func, def));
    def = "x1)"d;
    assert(!validateFunction(func, def));
    def = "x1x2"d;
    assert(!validateFunction(func, def));
    def = "x1+"d;
    assert(!validateFunction(func, def));
    def = "x1*x2"d;
    func = "(Number,Number)(Number)"d;
    assert(registerFunction("f"d, func, def));
    //Functions within functions were too hard to implement, so we removed them.
    //def =  "x1* f(x1,x2)(Number)"d;
    //assert(validateFunction(func, def));
}

/************************************
 * Converts a char to a dchar.
 *
 * Params:
 *     c =
 *        The char to convert.
 * Returns:
 *     The char converted to a dchar.
 */
package dchar d(char c) pure @safe
{
    return cast(dchar)c;
}

private void getParamsReturns(ref dstring[] input, immutable dstring func, ref size_t i) pure @safe //Get the types of the function parameters and the return types.
in
{
    assert(func[i] == d('('));
}
do
{
    ++i;
    do
    {
        ++input.length;
        do
        {
            input[$-1] ~= func[i];
            ++i;
        }
        while(func[i] != d(',') && func[i] != d(')'));

        if(func[i] != d(')'))
            ++i;
    }
    while(func[i] != d(')'));
}

//Function that checks whether using op currOp with type as its lhs and type2 as its rhs is valid.
private bool opCheckCrap(W, X)(W type, X type2, dstring currOp)//Please god let W and X be inferred from the arguments please.
{
    return type.applyOp(currOp, type2);
}

///We need the tuple type for executeFunction.
import std.typecons : Tuple;

/***********************************************************
 * Executes a function.
 *
 * TODO:  Actually write the function.
 * Params:
 *     func =
 *         The function to execute.
 *     args =
 *         The function arguments, expressed as a tuple.
 *     precision =
 *         The precision of the returned Mtype.
 * Returns:
 *     The result of calling the function.
 */
Return executeFunction(Return, Mtypes...)(in dstring func, in Tuple!(Mtypes) args, ulong precision = 18L) @safe
{
    debug import std;
    import std.uni : isNumber;
    
    // Create temporary stores for each mtype.
    static foreach(type; typel)
    {
        mixin(type ~ "[size_t][size_t]temp" ~ type ~ ";");
    }
    dstring[size_t][size_t] parens;
    parens[0] = [0 : ""d];
    // Parse the function
    size_t indentation = 0;
    size_t[size_t] parenNum;
    parenNum[0] = 0;
    for(size_t i = 0; i < funcList[func].length; ++i) // Organize the function into parentheses groups.
    {
        switch(funcList[func][i])
        {
            case d('('):
                ++indentation;
                if(indentation !in parens)
                {
                    parens[indentation] = [0 : ""d];
                    parenNum[indentation] = 0;
                }
                break;
            case d(')'):
                ++parenNum[indentation];
                --indentation;
                if(i+1 == funcList[func].length)
                    parens[indentation][parenNum[indentation]] ~= "()"d;
                else if(funcList[func][i+1] == d(')'))
                    parens[indentation][parenNum[indentation]] ~= "()"d;
                break;
            case d('x'):
                do
                {
                    parens[indentation][parenNum[indentation]] ~= funcList[func][i];
                    ++i;
                    if(i >= funcList[func].length)
                        break;
                }
                while(funcList[func][i].isNumber);
                --i;
                break;
            case d('\\'):
                do
                {
                    parens[indentation][parenNum[indentation]] ~= funcList[func][i];
                    ++i;
                }
                while(funcList[func][i] != d('\\'));
                break;
            default:
                if(funcList[func][i-1] == d(')'))
                    parens[indentation][parenNum[indentation]] ~= "()"d;
                parens[indentation][parenNum[indentation]] ~= funcList[func][i];
        }
    }
    //Sort the keys
    auto keys = parens.keys;
    import std.algorithm;
    keys.sort!"b > a";
    size_t[][] keys2;
    foreach(key; keys)
    {
        ++keys2.length;
        keys2[$-1] = parens[key].keys.dup;
    }
    foreach(ref key; keys2)
        key.sort!"b > a";
    foreach_reverse(key; keys)
    {
        debug import std.stdio;
        size_t currParen = 0;
        foreach(key2; keys2[key])
        {
            dstring currOp = ""d;
            dstring currType = ""d;
            bool firstOperand = false;
            for(size_t i = 0; i < parens[key][key2].length; i++)
            {
                //Get to work executing the function.
                switch(parens[key][key2][i])
                {
                    case d('('): //Parentheses, also known as a pain in the ass.
                        static foreach(type; typel)
                        {
                            mixin("if(temp" ~ type ~ "[key+1][currParen] !is null)
                            {
                                currType = type;
                                if(!firstOperand)
                                {
                                    temp" ~ type ~ "[key][key2] = new " ~ type ~ "(temp" ~ type ~ "[key+1][currParen].val);
                                }
                            }");
                        }
                        if(firstOperand)
                        {
                            bool c;
                            static foreach(type; typel)
                            {
                                if(type == currType)
                                    mixin("c = temp" ~ type ~ "[key][key2].applyOp(currOp, temp" ~ type ~ "[key+1][currParen]);");
                            }
                            assert(c);
                        }
                        else
                        {
                            firstOperand = true;
                        }
                        ++i;
                        ++currParen;
                        currOp = ""d;
                        break;
                    case d('x'): //Input
                        ++i;
                        dstring tempIndex = ""d;
                        dstring tempType = ""d;
                        do
                        {
                            tempIndex ~= parens[key][key2][i];
                            ++i;
                            if(i == parens[key][key2].length)
                                break;
                        }
                        while(parens[key][key2][i].isNumber);

                        static foreach(arg; 0 .. args.length) // Yes, this little fucker again.  You'll be meeting him alot in this file.
                        {
                            if(arg + 1 == to!size_t(tempIndex)) // Generates YandereDev spaghetti code, there is no workaround for this.
                                tempType = Unconst!(typeof(args[arg])).stringof;
                        }
                        
                        if(!firstOperand)
                        {
                            firstOperand = true;
                            static foreach(type; typel)
                            {
                                if(type == tempType)
                                {
                                    static foreach(arg; 0 .. args.length)
                                    {
                                        if(arg + 1 == to!size_t(tempIndex))
                                        {
                                            mixin("temp" ~ type ~ "[key][key2] = new " ~ type ~ "(args[arg].val);");
                                        }
                                    }
                                }
                            }
                            currType = tempType;
                        }
                        else
                        {
                            bool c;
                            static foreach(type; typel) // O(x * y) Compile Time.  D is the king of metaprogramming, but it's quite expensive.
                            {
                                if(type == currType)
                                {
                                    static foreach(arg; 0 .. args.length)
                                    {
                                        if(arg + 1 == to!size_t(tempIndex))
                                        {
                                            mixin("c = temp" ~ type ~ "[key][key2].applyOp(currOp, args[arg]);");
                                        }
                                    }
                                }
                            }
                            assert(c);
                        }
                        --i;
                        currOp = ""d;
                        break;
                    case d('\\'): //Operators, such as derivatives, sums, and integrals.
                        break;
                    default: //Type specific operators.
                        do
                        {
                            currOp ~= parens[key][key2][i];
                            ++i;
                            if(i == parens[key][key2].length)
                                break;
                        }
                        while(parens[key][key2][i] != d('\\') && parens[key][key2][i] != d('x') && parens[key][key2][i]
                        != d('('));
                        --i;
                }
            }
        }
    }
    static foreach(type; typel)
    {
        if(type == Return.stringof)
            mixin("return temp" ~ type ~ "[0][0];");
    }
    assert(0, "RubyTheRoobster sucks at programming... Please report this error.");
}

///
@trusted unittest
{
    Tuple!(Number, Number, Number) a;
    a[0] = new Number(NumberContainer(BigInt(2), BigInt(0), 0L, 18UL));
    a[1] = new Number(NumberContainer(BigInt(3), BigInt(0), 0L, 18UL));
    a[2] = new Number(NumberContainer(BigInt(1), BigInt(0), 0L, 18UL));
    dstring func = "(Number,Number,Number)(Number)"d;
    dstring def = "x1*x2*x3"d;
    auto r = registerFunction("ree"d, func, def);
    assert(r);
    auto i = executeFunction!(Number, Number, Number, Number)("ree(Number,Number,Number)(Number)"d, a);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
    assert(removeFunction("ree"d, func));
    def = "(x1*x2)*x3"d;
    assert(registerFunction("ree"d, func, def));
    i = executeFunction!(Number, Number, Number, Number)("ree(Number,Number,Number)(Number)"d, a);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
    // All of the above is working
    def = "x1*(x2*x3)"d;
    assert(removeFunction("ree"d, func));
    assert(registerFunction("ree"d, func, def));
    i = executeFunction!(Number, Number, Number, Number)("ree(Number,Number,Number)(Number)"d, a);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
    def = "(x1*x2)*x3*x4"d;
    assert(removeFunction("ree"d, func));
    func = "(Number,Number,Number,Number)(Number)"d;
    assert(registerFunction("ree"d, func, def));
    Tuple!(Number, Number, Number, Number) b;
    b[0] = new Number(NumberContainer(BigInt(2), BigInt(0), 0L, 18UL));
    b[1] = new Number(NumberContainer(BigInt(3), BigInt(0), 0L, 18UL));
    b[2] = new Number(NumberContainer(BigInt(1), BigInt(0), 0L, 18UL));
    b[3] = new Number(b[2].val);
    i = executeFunction!(Number, Number, Number, Number, Number)("ree(Number,Number,Number,Number)(Number)"d, b);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
    def = "x1*x2*(x3*x4)"d;
    assert(removeFunction("ree"d, func));
    assert(registerFunction("ree"d, func, def));
    i = executeFunction!(Number, Number, Number, Number, Number)("ree(Number,Number,Number,Number)(Number)"d, b);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
    def = "x1*(x2)*x3*(x4)"d;
    assert(removeFunction("ree"d, func));
    assert(registerFunction("ree"d, func, def));
    i = executeFunction!(Number, Number, Number, Number, Number)("ree(Number,Number,Number,Number)(Number)"d, b);
    assert(i.toDstring == "6+0i", cast(char[])i.toDstring.dup);
    assert(removeFunction("ree"d, func));
    def = "((x1)*((x2)*(x3)))*x4"d;
    assert(registerFunction("ree"d, func, def));
    i = executeFunction!(Number, Number, Number, Number, Number)("ree(Number,Number,Number,Number)(Number)"d, b);
    assert(i.toDstring == "6+0i"d, cast(char[])i.toDstring.dup);
}
