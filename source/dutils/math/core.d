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
/**Date: August 19, 2021*/
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
        static foreach(type; typel.keys)
        {
            mixin(typel[type] ~ "[] " ~ type ~ "ParamList;");
            mixin(typel[type] ~ "[] " ~ type ~ "OperandList;");
        }
        returns = returni[0];
        //Make sure that we know the types of of each parameter.
        dstring[] paramTypeList = [];
        dstring returnType = null;
        for(size_t j = 0; j < params.length; j++)
        {
            Switch: final switch(params[j])
            {
                static foreach(type; typel.keys)
                {
                    case typel[type]:
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
                static foreach(type; typel.keys)
                {
                    case typel[type]:
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
                        static foreach(type; typel.keys)
                        {
                            case type:
                                mixin(type ~ "OperandList ~= new "d ~ typel[type] ~ "();"d);
                                currOperand = typel[type];
                                break Switch3;
                        }
                    }
                    //Op verification.
                    if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                    {
                        Switch4: final switch(currOperand)
                        {
                            static foreach(type; typel.keys)
                            {
                                case typel[type]:
                                    Switch5: final switch(prevOp)
                                    {
                                        static foreach(type2; typel.keys)
                                        {
                                            case typel[type2]:
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
                            static foreach(type; typel.keys)
                            {
                                case typel[type]:
                                    Switch7: final switch(prevOp)
                                    {
                                        static foreach(type2; typel.keys)
                                        {
                                            case typel[type2]:
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
                default:
                    immutable oldi = i;
                    dchar[] tempstr = ""d.dup;
                    do
                    {
                        tempstr ~= def[i];
                        ++i;
                        if(i == def.length)
                        {
                            --i;
                            break;
                        }
                    }
                    while(def[i] != d(' ') && def[i] != d('('));
                    if(def[i] == d('(')) //Functions inside of functions.
                    {
                        immutable dstring oldtempstr = tempstr.idup;
                        for(ubyte j = 0; j < 2; j++)
                        {
                            do
                            {
                                tempstr ~= def[i];
                                ++i;
                            }
                            while(def[i] != d(')'));
                        }
                        tempstr ~= d(')');
                        ++i;
                        size_t j = 0;
                        prevOp = currOperand.idup;
                        if(isOperand && !isOp)
                            return false;
                        dstring[] tempstr2 = [];
                        dstring[] return2 = [];
                        //Get the function arguments
                        do
                        {
                            ++j;
                        }
                        while(tempstr[j] != d('('));
                        getParamsReturns(tempstr2, tempstr.idup, j);
                        ++j;
                        //Get the function return type
                        getParamsReturns(return2, tempstr.idup, j);
                        if(return2.length != 1)
                            return false;
                        currOperand = return2[0].idup;
                        Switch11: final switch(currOperand)
                        {
                            static foreach(type; typel.keys)
                            {
                                case type:
                                     currOperand = typel[type];
                                     break Switch11;
                            }
                        }
                        dstring temp;
                        //Get the function parameter types
                        foreach(ref arg; tempstr2)
                        {
                            tempNum = ""d;
                            j = 1;
                            assert(arg[0] == d('x'));
                            do
                            {
                                tempNum ~= arg[j];
                                ++j;
                            }
                            while(j < arg.length);
                            import std.conv : to;
                            arg = paramTypeList[to!size_t(tempNum) - 1];
                        }
                        tempstr = oldtempstr.dup;
                        tempstr ~= "("d;
                        foreach(arg; tempstr2)
                            tempstr ~= arg ~ ","d;
                        --tempstr.length;
                        tempstr ~= ")("d;
                        tempstr ~= currOperand;
                        tempstr ~= ")"d;
                        //Verify that the function used here is valid:
                        if(tempstr[0] == d(' '))
                        {
                            tempstr[0 .. $-1] = tempstr[1 .. $].dup;
                            --tempstr.length;
                        }
                        if(tempstr.idup !in funcList)
                            return false;
                        //Op verification.
                        if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                        {
                            Switch8: final switch(currOperand)
                            {
                                static foreach(type; typel.keys)
                                {
                                    case typel[type]:
                                        Switch9: final switch(prevOp)
                                        {
                                            static foreach(type2; typel.keys)
                                            {
                                                case typel[type2]:
                                                    mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], "
                                                    ~ type ~ "OperandList[0], currOp);");
                                                    if(!b)
                                                        return false;
                                                    break Switch9;
                                            }
                                        }
                                        break Switch8;
                                }
                            }
                        }
                        isOp = false;
                        isOperand = true;
                        ++i;
                    }
                    else
                    {
                        i = oldi;
                        if(isOp)
                            return false;
                        isOp = true;
                        isOperand = false;
                        tempstr = [];
                        do
                        {
                            tempstr ~= def[i];
                            if(((def[i] != d('x')) && (def[i] != d('\\'))) && (def[i] != d('(') && def[i] != d(' ')))
                                 ++i;
                        }
                        while((def[i] != d('x') && def[i] != d('\\')) && (def[i] != d('(') && def[i] != d(' ')));
                        currOp = tempstr.idup;
                    }
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
    def =  "x1* f(x1,x2)(Number)"d;
    assert(validateFunction(func, def));
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
    assert(func[i] == d('('), [cast(char)func[i]]);
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

/*********************************************************
 * Executes a function.
 *
 * Params:
 *     func =
 *         The function to execute.
 *     args =
 *         The function arguments, expressed as a tuple.
 * Returns:
 *     The result of calling the function.
 * Bugs:
 *     If parentheses are used in the function body before
       another operand, isOperand is wrongly set to `true`.
 */
Return executeFunction(Return, Mtypes...)(immutable dstring func, Tuple!(Mtypes) args)
{
    import std.uni : isNumber;

    Return ret = new Return();
    immutable dstring def = funcList[func];
    dstring returnType = ""d;
    dstring[] paramTypes = [];
    //Get the return type of the function, so we can dobule check if the template paramter `Return` is correct.
    size_t i = 0;
    do
    {
        ++i;
    }
    while(func[i] != d('('));
    ++i;
    do
    {
        returnType ~= func[i];
        ++i;
    }
    while(func[i] != d(')'));
    Switch1: final switch(returnType)
    {
        static foreach(type; typel.keys) //O(n) algortihm, where n is the number of keys in typel.
        {
            case type:
                if(typel[type] != Return.stringof)
                    throw new Exception("ERROR: INVALID RETURN TYPE " ~ Return.stringof ~ ", EXPECTED " ~ returnType);
                break Switch1;
        }
    }
    //Get the function parameter types and verify them.
    getParamsReturns(paramTypes, func, i);
    for(i = 0; i < paramTypes.length; ++i)
    {
        Switch2: final switch(paramTypes[i])
        {
            static foreach(type; typel)
            {
                case type:
                    Switch3: final switch(typeof(args[i]).stringof)
                    {
                        static foreach(type; typel)
                        {
                            case typel[type]:
                                if(type != paramTypes[i])
                                    throw new Exception("ERROR: IVALID PARAMETER " ~ paramTypes[i] ~ ", EXPECTED "
                                    ~ type);
                                break Switch3;
                        }
                    }
                    break Switch2;
            }
        }
    }

    dstring[][size_t] exprList;
    dstring[][size_t] exprGlue;
    bool isOperand = false;
    size_t currIndentation = 0;
    i = 0;

    do //Parse and seperate the function body into small peices, to make processing easier.
    {
        switch(def[i])
        {
            case d('('):
                isOperand = false;
                ++currIndentation;
                break;
            case d(')'):
                isOperand = true;
                --currIndentation;
                break;
            case d('x'):
                dstring tempNum = "x"d;
                ++i;
                do
                {
                    tempNum ~= def[i];
                    ++i;
                    if(i == def.length)
                        break;
                }
                while(def[i].isNumber);
                if(!isOperand)
                    ++exprList[currOperand].length;
                exprList[currOperand][$-1] ~= tempNum;
                isOperand = true;
                break;
            case d('\\'):
                dstring tempOp = "\\"d;
                ++i;
                do
                {
                    tempOp ~= def[i];
                    ++i;
                    if(i == def.length)
                        assert(0);
                }
                while(def[i] != d('\\'));
                if(!isOperand)
                    ++exprList[currOperand].length;
                exprList[currOperand][$-1] ~= tempOp;
                isOperand = true;
                break;
            default:
                auto oldi = i;
                dstring func;
                do
                {
                    func ~= def[i];
                    ++i;
                }
                while(def[i] != d('(') && i < def.length-1);
                if(i != def.length) //A function within a function.
                {
                    for(ubyte j = 0; j < 2; j++)
                    {
                        do
                        {
                            func ~= def[i];
                            ++i;
                        }
                        while(def[i] != d(')'));
                        func ~= d(')');
                        ++i;
                    }
                    if(!isOperand)
                        ++exprList[currOperand].length;
                    exprList[currOperand][$-1] ~= func;
                    isOperand = true;
                }
                else
                {
                    i = oldi;
                    dstring opName = ""d;
                    do
                    {
                        opName ~= def[i];
                        if((def[i] != d('x') && def[i] != d('\\')) && def[i] != d('('))
                            ++i;
                    }
                    while((def[i] != d('x') && def[i] != d('\\')) && def[i] != d('('));
                    if(opName[$-1] == d(' '))
                        --opName.length;

                    if(def[i] == d('(') && def[oldi] == d(')')) //If the operator is "gluing" two sets of parentheses together...
                        exprGlue[currIndentation] ~= opName;
                    else if(def[i] == d('('))
                        exprGlue[currIndentation] ~= opName ~ "("d;
                    else if(def[oldi] == d(')'))
                        exprGlue[currIndentation] ~= ")"d ~ opName;
                    else
                        exprList[currIndentation][$-1] ~= opName;
                }
        }
        ++i;
    }
    while(i < def.length);
    return ret;
}

///
@safe unittest
{
}
