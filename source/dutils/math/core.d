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
/**Date: August 2, 2021*/
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

/*********************************************************
 * Registers a valid function that doesn't already exists.
 *
 * Params:
 *    func =
 *        The function name and parameters.
 *    def =
 *        The definition of the function.
 *
 * Returns:
 *     Whether the function was registered.
 */
 
bool registerFunction(in dstring func, in dstring def) @safe
{
    auto ret = validateFunction(func, def) && func !in funcList.funcs;
    if(ret)
        funcList.funcs[func] = def;
    return ret;
}

/********************************************************
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
        size_t indentation = 0;
        do
        {
            tempNum = ""d;
            switch(def[i])
            {
                case d('('):
                    ++indentation;
                    break;
                case d(')'):
                    --indentation;
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
                            break;
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
                                                mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
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
                    if(i != def.length-1)
                        --i;
                    break;
                case d('\\'): //May possibly be even worse than above, as it denotes a special operator.
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
                    do
                    {
                        ++tempOps.length;
                        do
                        {
                            tempOps[$-1] ~= def[i];
                            ++i;
                        }
                        while(def[i] != d(',') && def[i] != d(')')); //Just in case.
                        bool a = (def[i] == d(')'));
                        ++i;
                        if(a && ((def[i] == d(',')) ^ (def[i] == d(')'))))
                            tempOps[$-1] ~= d(')'); //Fix bug about functions not working (I think I did, but I might be wrong).
                    }
                    while(def[i] != d(')'));
                    ++i;
                    if(def[i] != '\\')
                        return false;
                    //Get the types of the parameters referenced by the special operator call.
                    dstring[] tempTypes = [];
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
                    
                        Func:
                        k = 1;
                        //Function type header.
                        ++tempTypes.length;
                        tempTypes[$-1] = "f(x)"d;
                        //Get the function's return type (very easy, considering how it is specified).
                        do
                        {
                            tempNum ~= tempOp[k];
                            ++k;
                        }
                        while(tempOp[k] != d(')'));
                        ++k;
                        tempTypes[$-1] ~= tempNum;
                        tempTypes[$-1] ~= ")("d;
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

                            tempTypes[$-1] ~= paramTypeList[to!size_t(tempNum) - 1];
                            tempTypes[$-1] ~= d(',');
                        }

                        --tempTypes[$-1].length;
                        tempTypes[$-1] ~= d(')');
                        if(tempTypes[$-1][4 .. $-1] !in funcList)
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
                                                mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
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
                    --i;
                    break;
                default:
                    auto oldi = i;
                    dchar[] tempstr = [];
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
                    while(def[i] != d('('));
                    if(def[i] == d('(')) //Functions inside of functions.
                    {
                        prevOp = currOperand.idup;
                        if(isOperand && !isOp)
                            return false;                   
                        //Get the function return type, and set currOperand to it.
                        dchar[] tempstr2 = [];
                        ++i;
                        do
                        {
                            tempstr2 ~= def[i];
                            tempstr ~= def[i];
                            ++i;
                        }
                        while(def[i] != d(')'));
                        tempstr ~= def[i];
                        ++i;
                        Switch10: final switch(tempstr2)
                        {
                            static foreach(type; typel.keys)
                            {
                                case type:
                                    currOperand = typel[type];
                                    mixin(type ~ "OperandList ~= new "d ~ typel[type] ~ "();"d);
                                    break Switch10;
                            }
                        }
                        //Get the function parameters.
                        dstring[] tempOps = [];
                        do
                        {
                            ++tempOps.length;
                            do
                            {
                                tempOps[$-1] ~= def[i];
                                ++i;
                            }
                            while(def[i] != d(','));
                            ++i;
                        }
                        while(def[i-1] != d(')'));
                        //Get the types of the function parameters (pain).
                        dstring[] tempTypes = [];
                        foreach(tempOp; tempOps)
                        {
                            size_t j = 1;
                            if(tempOp[0] != d('x'))
                                return false;
                            do
                            {
                                tempNum ~= tempOp[j];
                                if(!tempOp[j].isNumber)
                                    return false;
                                j++;
                            }
                            while(j != tempOp.length);
                            ++tempTypes.length;
                            import std.conv : to;
                            tempTypes[$-1] = paramTypeList[to!size_t(tempNum) - 1];
                        }
                        tempstr ~= d('(');
                        foreach(tempOp; tempOps)
                        {
                            tempstr2 ~= tempOp;
                        }
                        tempstr2[$-1] = d(')');
                        foreach(type; tempTypes)
                        {
                            tempstr ~= type;
                            tempstr ~= d(',');
                        }
                        tempstr[$-1] = d(')');
                        //Verify that the function used here is valid:
                        if(tempstr !in funcList)
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
                                                    mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
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
                            if((def[i] != d('x')) && (def[i] != d('\\')))
                                 ++i;
                        }
                        while(def[i] != d('x') && def[i] != d('\\'));
                        currOp = tempstr.idup;
                        --i;
                    }
            }
            ++i;
        }
        while(i < def.length-1);
        if((isOp || !isOperand) || indentation != 0) //If there are no other syntax errors, ensure the following.
        {
            debug
            {
                import std.stdio;
                writeln(isOp);
                writeln(isOperand);
                writeln(indentation);
            }
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
    dstring func = "(Number,Number)(Number)"d;
    dstring def = "x1*x2"d;
    assert(validateFunction(func, def));
}

package dchar d(char c) pure @safe
{
    return cast(dchar)c;
}

package void getParamsReturns(ref dstring[] input, immutable dstring func, ref size_t i) pure @safe //Get the types of the function parameters and the return types.
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
package bool opCheckCrap(W, X)(W type, X type2, dstring currOp)//Please god let W and X be inferred from the arguments please.
{
    return type.applyOp(currOp, type2);
}

public import std.typecons;


