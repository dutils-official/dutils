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
/** License:  GPL-3.0*/
module dutils.skeleton;
/**Struct for representing a point.*/
public struct Point	{ //Point structure...
	///Point.x is the 'x' coordinate of the point.
	real x;
	///Point.y is the 'y' coordinate of the point.
	real y;
	///Point.z is the 'z' coordinate of the point.
	real z;
	this(real x, real y, real z)	{
		this.x = x;
		this.y = y;
		this.z = z;
	}
	void opAssign(Point rhs)	{
		this.x = rhs.x;
		this.y = rhs.y;
		this.z = rhs.z;
	}
	void opAssign(shared Point rhs) shared	{
		this.x = rhs.x;
		this.y = rhs.y;
		this.z = rhs.z;
	}

	void opOpAssign(string op)(Point rhs)	{
		mixin("this.x " ~ op ~ "= rhs.x;");
		mixin("this.y " ~ op ~ "= rhs.y;");
		mixin("this.z " ~ op ~ "= rhs.z;");
	}
	void opOpAssign(string op)(Point rhs) shared	{
		synchronized	{
			mixin("this.x = this.x " ~ op ~ " rhs.x;");
			mixin("this.y = this.y " ~ op ~ " rhs.y;");
			mixin("this.z = this.z " ~ op ~ " rhs.z;");
		}
	}
}
/**Struct for representing a face of a skeleton that is made out of lines.*/
public struct Face	{ //Face(of a 3D shape) structure...
	///Face.lines is an array of all the lines that connect to form the face.
	Line[] lines;
	///Face.center is the center point of the face.
	Point center;
	void opAssign(Face rhs)	{
		this.lines.length = rhs.lines.length;
		foreach(i;0 .. this.lines.length)	{
			this.lines[i] = rhs.lines[i];
		}
	}
	void opAssign(shared Face rhs)	shared {
		this.lines.length = rhs.lines.length;
		foreach(i;0 .. this.lines.length)	{
			this.lines[i] = rhs.lines[i];
		}
	}
}
/**Struct for representing a 3D skeleton.*/
public struct Skeleton	{ //Skeleton of a 3D structure...
	///Skeleton.faces is an array of the faces that make up the Skeleton.
	Face[] faces;
	///Skeleton.center is the center point of the skeleton.
	Point center;
	void opAssign(Skeleton rhs)	{
		this.faces.length = rhs.faces.length;
		foreach(i;0 .. this.faces.length)	{
			this.faces[i] = rhs.faces[i];
		}
		this.center = rhs.center;
	}
	void opAssign(shared Skeleton rhs) shared	{
		this.faces.length = rhs.faces.length;
		foreach(i;0 .. this.faces.length)	{
			this.faces[i] = rhs.faces[i];
		}
		this.center = rhs.center;
	}
}

/**Struct for representing a line composed of at least a starting point and an end point.
  *Notes:
  *This struct doesn't check to make sure that the line made is an actual line and assumes the user knows what they are doing.
*/
public struct Line	{ //Line struct...
	///Line.mid_points is an array containing all of the points that are neither start nor end points.
	Point[] mid_points;
	///Line.start is the start point of the line.
	Point start;
	///Line.end is the end point of the line.
	Point stop;
	void opAssign(Line rhs)	{
		this.start = rhs.start;
		this.stop = rhs.stop;
		this.mid_points.length = rhs.mid_points.length;
		foreach(i;0 .. this.mid_points.length)	{
			this.mid_points[i] = rhs.mid_points[i];
		}
	}
	void opAssign(shared Line rhs) shared	{
		this.start = rhs.start;
		this.stop = rhs.stop;
		this.mid_points.length = rhs.mid_points.length;
		foreach(i;0 .. this.mid_points.length)	{
			this.mid_points[i] = rhs.mid_points[i];
		}
	}
}
