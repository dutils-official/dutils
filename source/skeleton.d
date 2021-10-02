/*skeleton.d by Ruby The Roobster*/
/*Version 1.0 Release*/
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
/**Date: October 1, 2021*/
/** License:  GPL-3.0**/
module dutils.skeleton;
/**Struct for representing a point.
  *Members:
  *x
  *y
  *z
*/
public struct Point	{ //Point structure...
	real x;
	real y;
	real z;
	void opAssign(Point rhs)	{
		this.x = rhs.x;
		this.y = rhs.y;
		this.z = rhs.z;
	}
	void opOpAssign(string op)(Point rhs)	{
		mixin("this.x " ~ op ~ "= rhs.x;");
		mixin("this.y " ~ op ~ "= rhs.y;");
		mixin("this.z " ~ op ~ "= rhs.z;");
	}
}
/**Struct for representing a face of a skeleton that is made out of lines:
  *Members:
  *Line[] lines:  An array of the lines that make up the face.
  *Point center:  The center of the face.
*/
public struct Face	{ //Face(of a 3D shape) structure...
	Line[] lines;
	Point center;
	void opAssign(Face rhs)	{
		this.lines.length = rhs.lines.length;
		foreach(i;0 .. this.lines.length)	{
			this.lines[i] = rhs.lines[i];
		}
	}
}
/**Struct for representing a 3D skeleton.
  *Face[] faces: An array of all the faces making up the skeleton.
  *Point center: The center of the skeleton.
*/
public struct Skeleton	{ //Skeleton of a 3D structure...
	Face[] faces;
	Point center;
	void opAssign(Skeleton rhs)	{
		this.faces.length = rhs.faces.length;
		foreach(i;0 .. this.faces.length)	{
			this.faces[i] = rhs.faces[i];
		}
		this.center = rhs.center;
	}
}

/**Struct for representing a line composed of at least a starting point and an end point.
  *Members:
  *Point[] mid_points:  For storing all points that neither start nor end the line.
  *Point start:  The point that starts the line.
  *Point stop:  The point that ends the line.
  *Notes:
  *This struct doesn't check to make sure that the line made is an actual line and assumes the user knows what they are doing.
*/
public struct Line	{ //Line struct...
	Point[] mid_points;
	Point start;
	Point stop;
	void opAssign(Line rhs)	{
		this.start = rhs.start;
		this.stop = rhs.stop;
		this.mid_points.length = rhs.mid_points.length;
		foreach(i;0 .. this.mid_points.length)	{
			this.mid_points[i] = rhs.mid_points[i];
		}
	}
}
