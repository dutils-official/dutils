/*transform.d by Ruby The Roobster*/
/*Version 0.6.9 Release*/
/*Module for representing skeletons in the D Programming Language 2.0*/
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
/** Copyright: 2021, Ruby The Roobster*/
/**Author: Ruby The Roobster, michaeleverestc79@gmail.com*/
/**Date: December 22, 2021*/
/** License:  GPL-3.0*/
module dutils.transform;

public import dutils.skeleton;

/**Move all the points in the skeleton instantenously by a specified amount on each axis.
   Params:
    moveby =    The point that specifies how much to move on each axis.
	skele =    The skeleton to move.
   Returns:
    none
*/
public void move(in Point moveby, shared ref Skeleton skele)
{
    foreach(ref i;skele.faces)
	{
	    foreach(ref j; i.lines)
		{
		    foreach(ref k; j.mid_points)
			{
			    k += moveby;
			}
			j.start += moveby;
			j.stop += moveby;
		}
		i.center += moveby;
	}
	skele.center += moveby;
}

public import dutils.physics : Axis;

/**Scale all the points in the skeleton along a specified axis by a specified amount.
   Params:
    scale =    The amount to scale by.
	axis =    The axis on which to scale the skeleton on.
	skele =    The skeleton to scale.
   Returns:
    none
*/
public void scale(in real scale, in Axis axis, ref shared Skeleton skele)
{
    bruh:
    switch(axis)
	{
	    static foreach(a; ["x","y","z"])
		{
		    import dutils.physics : Axis;
		    mixin("case Axis." ~ a ~ ":");
			foreach(ref i; skele.faces)
		    {
				foreach(ref j; i.lines)
				{
				    foreach(ref k; j.mid_points)
					{
					    mixin("k." ~ a ~ " = ((k." ~ a ~ " - skele.center." ~ a ~ ") * scale) + skele.center." ~ a ~ ";");
					}
					mixin("j.stop." ~ a ~ " = ((j.stop." ~ a ~ " - skele.center." ~ a ~ ") * scale) + skele.center." ~ a ~ ";");
					mixin("j.start." ~ a ~ " = ((j.start." ~ a ~ " - skele.center." ~ a ~ ") * scale) + skele.center." ~ a ~ ";");
				}
				mixin("i.center." ~ a ~ " = ((i.center." ~ a ~ " - skele.center." ~ a ~ ") * scale) + skele.center." ~ a ~ ";");
			}
			mixin("break bruh;");
		}
		default:
		    throw new Exception("Invalid axis, somehow.  Either you tampered with the library, or I screwed up.  If you haven't tampered with this library, please file an issue.");
	}
}

public import dutils.physics : Plane;

/**Rotates an object along a plane by a specifed amount of degrees.
   Params:
    degrees =    The number of radians to rotate by.
	plane =    The plane on which to rotate.
	skele =    The skeleton to rotate.
   Returns:
    none
*/
public void rotate(in real degrees, in Plane plane, ref shared Skeleton skele)
{
    import std.math.algebraic : abs;
	import std.math.trigonometry : sin;
	import std.math.trigonometry: cos;
    bruh:
	switch(plane)
	{
	    static foreach(a; ["xy", "xz", "zy"])
		{
		    mixin("case Plane." ~ a ~ ":");
			foreach(ref i; skele.faces)
			{
			    foreach(ref j; i.lines)
				{
				    foreach(ref k; j.mid_points)
					{
					    mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - k." ~ [a[0]] ~ "));"); //Define the radius of the circle of rotation.
						//Do the rotation thingy.
						mixin("k." ~ [a[0]] ~ " = (cos(degrees) * radius) + skele.center." ~ [a[0]] ~ ";");
						//As above
						mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - k." ~ [a[1]] ~ "));");
						mixin("k." ~ [a[1]] ~ " = (sin(degrees) * radius) + skele.center." ~ [a[1]] ~ ";");
					}
                    //Rinse and Repeat!
                    mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - j.start." ~ [a[0]] ~ "));");
					mixin("j.start." ~ [a[0]] ~ " = (cos(degrees) * radius) + skele.center." ~ [a[0]] ~ ";");
					mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - j.start." ~ [a[1]] ~ "));");
					mixin("j.start." ~ [a[1]] ~ " = (sin(degrees) * radius) + skele.center." ~ [a[1]] ~ ";");
					mixin("radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - j.stop." ~ [a[0]] ~ "));");
					mixin("j.stop." ~ [a[0]] ~ " = (cos(degrees) * radius) + skele.center." ~ [a[0]] ~ ";");
					mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - j.stop." ~ [a[1]] ~ "));");
					mixin("j.stop." ~ [a[1]] ~ " = (sin(degrees) * radius) + skele.center." ~ [a[1]] ~ ";");
				}
				mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - i.center." ~ [a[0]] ~ "));");
				mixin("i.center." ~ [a[0]] ~ " = (cos(degrees) * radius) + skele.center." ~ [a[0]] ~ ";");
				mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - i.center." ~ [a[1]] ~ "));");
				mixin("i.center." ~ [a[1]] ~ " = (sin(degrees) * radius) + skele.center." ~ [a[1]] ~ ";");
			}
			mixin("break bruh;");
		}
		default:
		    throw new Exception("Invalid Plane, somehow.  Either I screwed up or you did.  If you didn't touch the code, open an issue.");
	}
}

/**Scales all the points in the Skeleton along all axises by a specifed amount.
   Params:
    scale =    The amount to scale by.
	skele =    The skeleton to scale.
   Returns:
    none
*/
public void fullScale(in real scale, ref shared Skeleton skele)
{
    foreach(ref i; skele.faces)
	{
	    foreach(ref j; i.lines)
		{
		   foreach(ref k; j.mid_points)
		   {
		       k = ((k - skele.center) * scale) + skele.center;
		   }
		   j.start = ((j.start - skele.center) * scale) + skele.center;
		   j.stop = ((j.stop - skele.center) * scale) + skele.center;
		}
		i.center = ((i.center - skele.center) * scale) + skele.center;
	}
}