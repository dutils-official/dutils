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
/**Date: September 14, 2022*/
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
                default: //Operators
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
                    currOp = tempstr.idup;
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
 * Params:
 *     func =
 *         The function to execute.
 *     args =
 *         The function arguments, expressed as a tuple.
 *     precision =
 *         The precision of the returned Mtype.
 * Returns:
 *     The result of calling the function.
 * TODO:
 *     There is a section of the loop pertaining to
 *     operator execution on paramaters that gets executed
 *     twice.  This has been patched, but an actual solution
 *     is wanted.
 */
Return executeFunction(Return, Mtypes...)(in dstring func, in Tuple!(Mtypes) args, ulong precision = 18L) @safe
{
    import std.algorithm;
    import std.conv : to;
    size_t i = 0;
    //Generate a temporary store for each type
    static foreach(type; typel)
        mixin(type ~ "[size_t][size_t] temp"d ~ type ~ ";"d);

    import std.uni : isNumber;
    bool isOp = false;
    bool isOperand = false;
    Return ret = new Return();
    immutable dstring def = funcList[func];
    dstring returnType = ""d;
    dstring[] paramTypes = [];
    //Get the function parameter types and verify them.
    do
    {
        ++i;
    }
    while(func[i] != d('('));
    getParamsReturns(paramTypes, func, i);
    size_t j = 0;
    for(; i < paramTypes.length; ++i)
    {
        static foreach(ree; 0 .. args.expand.length)
        {
            mixin("e" ~ to!string(ree) ~ ": final switch(paramTypes[i])
            {
                static foreach(type; typel)
                {
                    case type:
                        import std.traits;
                        mixin(\"Switch12\" ~ to!string(ree) ~ \": final switch(Unqual!(typeof(args[ree])).stringof)
                        {
                            static foreach(type; typel)
                            {
                                case type:
                                    if(type != paramTypes[i])
                                        throw new Exception(\\\"ERROR: IVALID PARAMETER \\\"
                                        ~ cast(string)paramTypes[i] ~ \\\", EXPECTED \\\"
                                        ~ cast(string)type.idup);
                                    break Switch12\" ~ to!string(ree) ~ \";
                            }
                        }\");
                        break e" ~ to!string(ree) ~ ";
                }
            }");
        }
    }
    //Get the return type of the function, so we can dobule check if the template paramter `Return` is correct.
    ++i;
    do
    {
        returnType ~= func[i];
        ++i;
    }
    while(func[i] != d(')'));
    auto returnType2 = returnType[1 .. $].idup;
    returnType = returnType2;
    Switch10: final switch(returnType)
    {
        static foreach(type; typel) //O(n) algortihm, where n is the number of keys in typel.
        {
            case type:
                if(type != Return.stringof)
                    throw new Exception("ERROR: INVALID RETURN TYPE " ~ Return.stringof ~ ", EXPECTED " ~ cast(string)returnType);
                break Switch10;
        }
    }

    dstring[][size_t] exprList;
    dstring[size_t][size_t][size_t] exprGlue;
    dstring[][size_t] tempTypes;
    size_t currIndentation = 0;
    exprList[0].length = 1;
    size_t[size_t] begins;
    begins[0] = 0;
    size_t oldi = 0;
    size_t[size_t][size_t][size_t] endGlue;
    //Parse the function body:
    for(i = 0; i < def.length; i++)
    {
        switch(def[i])
        {
            case d('('):
                ++currIndentation;
                begins[currIndentation] = i;
                exprList[currIndentation].length = exprList[currIndentation].length + 1 ;
                break;
            case d(')'):
                --currIndentation;
                break;
            case d('x'): //Parameters
                dstring tempNum = ""d;
                do
                {
                    tempNum ~= def[i];
                    ++i;
                    if(i == def.length)
                        break;
                }
                while(def[i].isNumber);
                exprList[currIndentation][$-1] ~= tempNum;
                --i;
                break;
            case d(' '):
                exprList[currIndentation][$-1] ~= def[i];
                break;
            case d('\\'): //Sepcial Operators
                dstring tempOperator = "\\"d;
                ++i;
                do
                {
                    tempOperator ~= def[i];
                    ++i;
                    if(i == def.length)
                        break;
                }
                while(def[i] != d('\\'));
                tempOperator ~= "\\"d;
                break;
            default: //Operators
                oldi = i - 1;
                dstring tempOp = ""d;
                do
                {
                    tempOp ~= def[i];
                    debug
                    {
                        import std.stdio;
                        writeln(tempOp);
                    }
                    ++i;
                }
                while(def[i] != d(' ') && def[i] != d('x') && def[i] != d('\\') && def[i] != d('(')
                && def[i] != d(')'));
                --i;
                if(def[oldi] == d(')') && def[i+1] == d('('))
                    exprGlue[currIndentation][exprList[currIndentation].length-1][i - begins[currIndentation]] = ")"d ~ tempOp ~ "("d;
                else if(def[oldi] == d(')') && def[i+1] != d('('))
                    exprGlue[currIndentation][exprList[currIndentation].length-1][i - begins[currIndentation]] = ")"d ~ tempOp;
                else if(def[oldi] != d(')') && def[i+1] == d('('))
                    exprGlue[currIndentation][exprList[currIndentation].length-1][i - begins[currIndentation]] = tempOp ~ "("d;
                else
                    exprList[currIndentation][$-1] ~= tempOp;
                debug
                {
                    import std.stdio;
                    writeln("i:", i);
                    writeln("currIndentation:", currIndentation);
                }
        }
    }
    //Compute the values of exprList.
    dstring currOperand = ""d;
    dstring currOp = ""d;
    auto keys = exprList.keys.sort!"b > a";
    debug
    {
        import std.stdio;
        writeln("Firstprint");
        writeln(exprList[0][0]);
        writeln(exprGlue);
        writeln(keys);
    }
    import std.traits : Unconst;
    size_t currIndentI = 0;
    for(size_t key = keys[$-1]; key <= keys[$-1]; --key)
    {
        currIndentI = 0;
        for(i = 0; i < exprList[key].length; i++)
        {
            bool c = false;
            tempTypes[key].length = i+1;
            isOp = false;
            isOperand = false;
            size_t firstOp = 0;
            for(j = exprList[key][i].length-1; j < exprList[key][i].length; j--)
            {
                debug
                {
                    writeln(j);
                    writeln(tempTypes);
                }
                if(key in exprGlue)
                {
                    debug writeln("OH HERRO!");
                    if(i in exprGlue[key])
                    {
                        debug writeln("OH HERRO! ", j+exprList[key+1][currIndentI].length+firstOp+1);
                        if(j+exprList[key+1][currIndentI].length+firstOp+1 in exprGlue[key][i] && !c) //Glue stuff together
                        {
                            c = true;
                            debug writeln("INGLUE");
                            auto k = j+exprList[key+1][currIndentI].length+firstOp+1;
                            auto keys2 = exprGlue[key][i].keys.sort!"b < a";
                            import std.algorithm.searching : findSplitBefore;
                            size_t pos = 0;
                            for(; keys2[pos] != j+exprList[key+1][currIndentI].length+firstOp+1; pos++)
                            {
                            }
                            if(exprGlue[key][i][k][0] == d(')') && exprGlue[key][i][k][$-1] == d('('))
                            {
                                currOp = exprGlue[key][i][k][1 .. $-1].idup;
                            }
                            else if(exprGlue[key][i][k][0] == d(')') && exprGlue[key][i][k][$-1] != d('('))
                            {
                                isOp = false;
                                if(!isOperand)
                                    goto Num;
                                c = false;
                                j -= firstOp+1;
                                currOp = exprGlue[key][i][k][1 .. $].idup;
                                Paren3: final switch(tempTypes[key+1][pos])
                                {
                                    static foreach(type; typel)
                                    {
                                        case type:
                                            mixin("Paren3" ~ type ~ ": final switch(tempTypes[key][i])
                                            {
                                                static foreach(type2; typel)
                                                {
                                                    case type2:
                                                        mixin(\"auto temp2 = new \" ~ type ~ \"(temp\" ~ type ~ \"[key+1][pos].val);\");
                                                        mixin(\"temp2.applyOp(currOp, temp\" ~ type2 ~ \"[key][i]);\");
                                                        mixin(\"temp\" ~ type ~ \"[key][i] = new \" ~ type ~ \"(temp2.val);\");
                                                        tempTypes[key][i] = type;
                                                        break Paren3" ~ type ~ ";
                                                }
                                            }");
                                            break Paren3;
                                    }
                                }
                                continue;
                            }
                            else
                            {
                                currOp = exprGlue[key][i][k][0 .. $-1].idup;
                            }
                        }
                    }
                }
                Num:
                if(exprList[key][i][j].isNumber) //Take care of parameters.
                {
                    debug
                    {
                        writeln("HERE");
                    }
                    dstring tempNum = ""d;
                    tempNum = ""d;
                    do
                    {
                        tempNum ~= exprList[key][i][j];
                        --j;
                    }
                    while(exprList[key][i][j].isNumber);
                    tempNum = tempNum.dup.reverse.idup;
                    if(isOp)
                    {
                        r: final switch(to!size_t(tempNum)-1)
                        {
                            static foreach(tempNumber2; 0 .. args.fieldNames.length)
                            {
                                case tempNumber2:
                                    bool ins = false;
                                    static foreach(ree; 0 .. args.fieldNames.length)
                                    {
                                        mixin("Switch14"d ~ to!dstring(ree) ~ to!dstring(tempNumber2) ~ ": final switch(to!dstring(Unconst!(typeof(args[tempNumber2])).stringof))
                                        {
                                            static foreach(type; typel)
                                            {
                                                case type:
                                                    mixin(\"Switch15\"d ~ type ~ to!dstring(ree) ~ to!dstring(tempNumber2) ~\": final switch(tempTypes[key][i])
                                                    {
                                                        static foreach(type2; typel)
                                                        {
                                                            case type2:
                                                                if(!ins)
                                                                {
                                                                    ins = true;
                                                                    mixin(type ~ \\\"[size_t][size_t] temp2;\\\"d);
                                                                    mixin(\\\"foreach(bruh1; temp\\\" ~ type ~ \\\".keys)
                                                                    {
                                                                        foreach(bruh2; temp\\\" ~ type ~ \\\"[bruh1].keys)
                                                                        {
                                                                            temp2[bruh1][bruh2] = new \\\" ~ type ~ \\\"(temp\\\" ~ type ~ \\\"[bruh1][bruh2].val);
                                                                        }
                                                                    }\\\");
                                                                    mixin(\\\"temp2[key][i] = new \\\" ~ type ~ \\\"(args[tempNumber2].val);\\\");
                                                                    mixin(\\\"temp2[key][i].applyOp(currOp, temp\\\"d
                                                                    ~ type2 ~ \\\"[key][i]);\\\"d);
                                                                    mixin(\\\"temp\\\" ~ type ~ \\\" = temp2;\\\");
                                                                    tempTypes[key][i] = Unconst!(typeof(args[tempNumber2])).stringof;
                                                                    break Switch15\"d ~ type ~ to!dstring(ree) ~ to!dstring(tempNumber2) ~ \";
                                                                }
                                                        }
                                                    }\"d);
                                                    break Switch14"d ~ to!dstring(ree) ~ to!dstring(tempNumber2) ~  ";
                                            }
                                        }"d);
                                    }
                                    break r;
                            }
                        }
                    }
                    else
                    {
                        if(!isOperand)
                            firstOp = j;
                        debug writeln(key == 0);
                        REEE: final switch(to!size_t(tempNum)-1)
                        {
                            static foreach(tempNumber3; 0 .. args.expand.length)
                            {
                                case tempNumber3:
                                    mixin("Switche" ~ to!string(tempNumber3) ~ ": final switch(Unconst!(typeof(args[tempNumber3])).stringof)
                                    {
                                        static foreach(type; typel)
                                        {
                                            case type:
                                                mixin(\"z\" ~ to!string(tempNumber3) ~ \": final switch(to!size_t(tempNum)-1)
                                                {
                                                    static foreach(tempNumber2;  0 .. args.expand.length) //REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE
                                                    {
                                                        case tempNumber2:
                                                            mixin(\\\"temp\\\"d ~ type ~ \\\"[key][i] = new \\\"d  ~ type ~
                                                            \\\"(args[tempNumber2].val);\\\"d);
                                                            mixin(\\\"tempTypes[key][i] =\\\" ~ type.stringof ~ \\\";\\\");
                                                            debug
                                                            {
                                                                writeln(\\\"NOOP: \\\", tempNumber3);
                                                                mixin(\\\"writeln(temp\\\" ~ type ~ \\\"[key][i].toDstring);\\\");
                                                            }
                                                            break z\" ~ to!string(tempNumber3) ~ \";
                                                    }
                                                }\");
                                                break Switche" ~ to!string(tempNumber3) ~ ";
                                        }
                                    }");
                                    break REEE;
                            }
                        }
                        if(c)
                            j += firstOp+tempNum.length+1; //Shouldn't end here, by definition.
                    }
                    isOp = false;
                    isOperand = true;
                    currOperand = "x"d ~ tempNum;
                    debug writeln("TEMPTYPES:", tempTypes);
                    c = false;
                }
                else if(exprList[key][i][j] == d('\\')) //Special Operator
                {
                    c = false;
                    //TODO: FIX BUGS WHEN DISCOVERED.
                    dstring tempSpecOperator = ""d;
                    returnType = ""d;
                    size_t ind = 0;
                    bool ifParam = false;
                    bool ifParam2 = false;
                    do
                    {
                        tempSpecOperator ~= exprList[key][i][j];
                        --j;
                    }
                    while(exprList[key][i][j] != d('\\'));
                    tempSpecOperator = tempSpecOperator.dup.reverse.idup;
                    //Get the return type of the operator
                    do
                    {
                        returnType ~= tempSpecOperator[ind];
                        ++ind;
                    }
                    while(tempSpecOperator[ind] != d('('));
                    //Replace the `xnnn`s with the value of args[nnn].toDstring.
                    size_t k = 0;
                    size_t oldk = 0;
                    dstring num = ""d;
                    bool firstx = false;
                    do
                    {
                        do
                        {
                            if(!firstx)
                                ind = k;
                            ++k;
                        }
                        while(tempSpecOperator[k] != d('x'));
                        firstx = true;
                        oldk = k;
                        ++k;
                        do
                        {
                            num ~= tempSpecOperator[k];
                            ++k;
                        }
                        while(tempSpecOperator[k].isNumber);
                    }
                    while(k < tempSpecOperator.length);
                    dstring tem = ""d;
                    BRUH: final switch(to!size_t(num)) //I SWEAR THAT I AM SICK AND TIRED OF THIS FUCKING SHIT
                    {
                        static foreach(Number2; 0 .. args.expand.length)
                        {
                            case Number2:
                                tem = args[Number2].toDstring;
                                break BRUH;
                        }
                    }
                    dchar[] tempSpecOperator2 = tempSpecOperator.dup;
                    tempSpecOperator2.length += tem.length - num.length -1;
                    tempSpecOperator2[0 .. oldk+1] = tempSpecOperator[0 .. oldk+1].dup;
                    tempSpecOperator2[oldk+1 .. oldk+tem.length-num.length] = tem.dup;
                    tempSpecOperator2[oldk+tem.length-num.length .. $] = tempSpecOperator[oldk+1 .. $].dup;
                    tempSpecOperator = tempSpecOperator2.idup;
                    //Execute the special operator
                    auto tem2 = tempSpecOperator[0 .. ind].idup;
                    tem = tempSpecOperator[ind .. $].idup;
                    dstring[] paramatar = [];
                    k = 0;
                    getParamsReturns(paramatar, tem, k);
                    tem = opList[tem2](paramatar);
                    if(isOp)
                    {
                        amogus: final switch(cast(string)returnType)
                        {
                            static foreach(type; typel)
                            {
                                    mixin("amogus" ~ type ~ ": final switch(cast(string)tempTypes[key][i])
                                    {
                                        static foreach(type2; typel)
                                        {
                                            case type2:
                                                mixin(\"temp\"d ~ type ~ \"[key][i] = new \"d  ~ type ~
                                                \"(precision);\"d);
                                                mixin(\"temp\" ~ type ~ \"[key][i].fromDstring(tem);\");
                                                mixin(\"temp\" ~ type ~ \"[key][i].applyOp(currOp, temp\" ~ type2 ~ \"[key][i]);\");
                                                break amogus" ~ type ~ ";
                                        }
                                    }"d);
                                    break amogus;
                            }
                        }
                    }
                    else
                    {
                        amogusrofl: final switch(cast(string)returnType)
                        {
                            static foreach(type; typel)
                            {
                                case type:
                                    mixin("temp" ~ type ~ "[key][i] = new " ~ type ~ "(precision);");
                                    mixin("temp" ~ type ~ "[key][i].fromDstring(tem);");
                                    break amogusrofl;
                            }
                        }
                    }
                    tempTypes[key][i] = returnType;
                    isOp = false;
                    isOperand = true;
                }
                else if(exprList[key][i][j] == d(' ')) //The obligatory whitespace after an operator and before a function.
                    continue;
                else //Operator
                {
                    c = false;
                    debug
                    {
                        writeln("HEREOP");
                    }
                    dstring tempOp = ""d;
                    isOp = true;
                    do
                    {
                        tempOp ~= exprList[key][i][j];
                        --j;
                    }
                    while(exprList[key][i][j] != d('\\') && exprList[key][i][j] != d(' ') &&
                    !exprList[key][i][j].isNumber && exprList[key][i][j] != d(')'));
                    debug writeln(tempOp, tempOp.length);
                    ++j;
                    tempOp = tempOp.dup.reverse.idup;
                    currOp = tempOp;
                }
            }
        }
    }
    BRUHBRUH: final switch(Return.stringof)
    {
        static foreach(type; typel)
        {
            case type:
                mixin("ret = new " ~ type ~ "(temp" ~ type ~ "[0][0].val);");
                break BRUHBRUH;
        }
    }
    isOp = false;
    isOperand = true;
    currOp = ""d;
    return ret;
}
///
@safe unittest
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
}
