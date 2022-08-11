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
 
bool registerFunction(immutable dstring func, immutable dstring def)
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
 
bool validateFunction(dstring func, dstring def) @trusted
{
    dstring[] params;
    dstring[] returni;
    import std.string : strip;
    func = func.strip;
    def = def.strip;
    size_t i = 0;
    getParamsReturns(returni, func, i); //Get the function return type.
    dstring returns;
    try
    {
        returns = returni[0];
    }
    catch(Exception e)
    {
        return false;
    }
    ++i; //Make sure to get out of the closing parenthesis.
    getParamsReturns(params, func, i); //Get the parameter types.
    static foreach(type; typel.keys)
    {
        mixin(typel[type] ~ "[] " ~ type ~ "ParamList;");
        mixin(typel[type] ~ "[] " ~ type ~ "OperandList;");
    }
    //Make sure that we know the types of of each parameter.
    dstring[] paramTypeList = [];
    dstring returnType = null;
    for(size_t j = 0; j < params.length; j++)
    {
        switch(params[j])
        {
            static foreach(type; typel.keys)
            {
                case typel[type]:
                    mixin("++" ~ type ~ "ParamList.length;");
                    ++paramTypeList.length;
                    paramTypeList[j] = type;
                    break;
            }
            default:
                return false;
        }
    }
    //Get the return type.
    for(size_t j = 0; j < 1; j++)
    {
        switch(returns)
        {
            static foreach(type; typel.keys)
            {
                case typel[type]:
                    returnType = type;
                    break;
            }
            default:
                return false;
        }
    }   
    //This gets scary.
    //Buckle up.
    bool isOperand = false;
    bool isOp = false;
    dstring currOperand;
    dstring currOp;
    import std.uni : isNumber;
    for(i = 0; i < def.length; i++)
    {
        switch(def[i])
        {
            case d('x'): //Uh-oh
                if(isOperand && !isOp)
                    return false;
                dstring prevOp = currOperand.idup;
                isOperand = true;
                ++i;
                if(!def[i].isNumber) //Forced indexing of parameters.
                    return false;
                dstring tempNum; 
                do
                {
                    tempNum ~= def[i];
                    ++i;
                }
                while(def[i].isNumber);
                import std.conv : to;
                dstring tempType;
                tempType = paramTypeList[to!size_t(tempNum)];
                final switch(tempType)
                {
                    static foreach(type; typel.keys)
                    {
                        case type:
                            mixin(type ~ "OperandList ~= new " ~ typel[type] ~ "();");
                            currOperand = typel[type];
                            break;
                    }
                }
                //Op verification.
                if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                {
                    final switch(currOperand)
                    {
                        static foreach(type; typel.keys)
                        {
                            case typel[type]:
                                final switch(prevOp)
                                {
                                    static foreach(type2; typel.keys)
                                    {
                                        case typel[type2]:
                                            mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
                                            if(!b)
                                                return false;
                                            break;
                                    }
                                }
                                break;
                        }
                    }
                }
                break;
            case d('\\'): //May possibly be even worse than above, as it denotes a special operator.
                if(isOperand && !isOp)
                    return false;
                isOperand = true;
                dstring opName;
                dstring prevOp = currOperand.idup;
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
                        tempOps[$-1] ~= d(')'); //Fix bug about functions not working.
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
                    dstring tempNum = ""d;
                    
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
                    tempTypes[$-1] = paramTypeList[to!size_t(tempNum)];
                    
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

                        tempTypes[$-1] ~= paramTypeList[to!size_t(tempNum)];
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
                //Op verification.
                if(isOp) //Speed on this gonna be O(n^2), where n is typel.keys.length, both compilation and runtime.
                {
                    final switch(currOperand)
                    {
                        static foreach(type; typel.keys)
                        {
                            case typel[type]:
                                final switch(prevOp)
                                {
                                    static foreach(type2; typel.keys)
                                    {
                                        case typel[type2]:
                                            mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
                                            if(!b)
                                                return false;
                                            break;
                                    }
                                }
                                break;
                        }
                    }
                }
                break;
            default:
                auto oldi = i;
                dchar[] tempstr = [];
                do
                {
                    tempstr ~= def[i];
                    ++i;
                }
                while(def[i] != d('(') && i != def.length - 2 );
                if(i != def.length - 2) //Functions inside of functions.
                {
                    dstring prevOp = currOperand.idup;
                    if(isOperand || !isOp)
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
                    final switch(tempstr2)
                    {
                        static foreach(type; typel.keys)
                        {
                            case type:
                                currOperand = typel[type];
                                mixin(type ~ "OperandList ~= new " ~ typel[type] ~ "();");
                                break;
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
                        dstring tempNum;
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
                        tempTypes[$-1] = paramTypeList[to!size_t(tempNum)];
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
                        final switch(currOperand)
                        {
                            static foreach(type; typel.keys)
                            {
                                case typel[type]:
                                    final switch(prevOp)
                                    {
                                        static foreach(type2; typel.keys)
                                        {
                                            case typel[type2]:
                                                mixin("bool b = opCheckCrap(" ~ type2 ~ "OperandList[0], " ~ type ~ "OperandList[0], currOp);");
                                                if(!b)
                                                    return false;
                                                break;
                                        }
                                    }
                                    break;
                            }
                        }
                    }
                }
                else if(i == def.length - 2)
                    return false;
                else //Otherwise, an operator specific to a math type.
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
                        ++i;
                    }
                    while(def[i] != d('x') && def[i] != d('\\'));
                    --i;
                    currOp = tempstr.idup;
                }
                return false;
        }
    }
    if(isOp || !isOperand) //If there are no other syntax errors, ensure the following.
        return false;
    return true;
}

package dchar d(char c) pure @safe
{
    return cast(dchar)c;
}

package void getParamsReturns(ref dstring[] input, immutable dstring func, ref size_t i) pure @safe //Get the types of the function parameters and the return types.
{
    for(; func[i] != cast(dchar)')'; i++)
    {
        if(func[i] == cast(dchar)'(')
        {
            input.length = 1;
            ++i;
            for(; func[i] != cast(dchar)','; i++)
            {
                input[$-1] ~= func[i];
            }
        }
        if(func[i] == cast(dchar)',')
        {
            ++input.length;
            ++i;
            for(; func[i] != cast(dchar)','; i++)
            {
                input[$-1] ~= func[i];
            }
        }
    }
}

//Function that checks whether using op currOp with type as its lhs and type2 as its rhs is valid.
package bool opCheckCrap(W, X)(Mtype!W type, Mtype!X type2, dstring currOp) //Please god let W and X be inferred from the arguments please.
{
    return type.applyOp(currOp, type2);
}
