module dutils.math.core;

version(DLL)
{
	mixin("export:");
}

else
{
	mixin("public:");
}

import std.complex;

alias Operator = dstring function(dstring input);

//List of all operations.
package Operator[dstring] opList;

//List of all functions.
package dstring[dstring] funcList;

//Initialize the basic arithmetic operations to null: these will be handled by operator overloading.
shared static this()
{
    opList["+"d] = null;
	opList["-"d] = null;
	opList["*"d] = null;
	opList["/"d] = null;
	opList["^^"d] = null;
}

//An interface that serves as the basis for all math types.
package interface mType
{
	mType opBinary(string op)(mType rhs);
	mType opBinary(string op)(Complex!real rhs);
	
	mType opBinaryRight(string op)(mType lhs);
	mType opBinaryRight(string op)(Complex!real lhs);
	
	mType opUnary(string op);
}

/**************************************************
 * Validates the math library's fucntion syntax.
 * TODO: Make syntax rules modular.
 *
 * Params:
 *     funcbody = The body of the function to validate.
 * Returns: true if the function has correct syntax, false otherwise.
 */
bool validateFunction(dstring funcbody) pure @safe @nogc
{
	import std.uni : isSpace;
	
	uint indentation = 0;
	bool isOp = false;
	bool isNum = false;
	bool isDec = false;
	ubyte powCount = 0;
	
	foreach(c; funcbody)
	{
	    switch(c)
		{
			case cast(dchar)'x':
				isOp = false;
			    continue;
				break;
				
			static foreach(x; [cast(dchar)'+', cast(dchar)'-', cast(dchar)'*', cast(dchar)'/'])
			{
				case x:
					if(isOp)
						return false;
						
					isOp = true;
					powCount = 0;
					continue;
				    break;
			}
			
			case cast(dchar)'^':
				if(isOp)
					return false;
					
				switch(powCount)
				{
					case 0:
						++powCount;
						break;
					case 1:
						++powCount;
						isOp = true;
						break;
					default:
						return false;
				}
				continue;
				break;
				
			default:
				
    return true;
}
