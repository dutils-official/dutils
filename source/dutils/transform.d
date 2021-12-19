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
/**Date: December 18, 2021*/
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