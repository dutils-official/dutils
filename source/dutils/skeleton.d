/*skeleton.d by Ruby The Roobster*/
/*Version 1.0.1 Release*/
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
module dutils.skeleton;
/**Structure for representing a point.*/
public struct Point	{ //Point structure...
	///The x coordinate of the point.
	real x;
	///The y coordinate of the point.
	real y;
	///The z coordinate of the point.
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
        this = this.opBinary!op(rhs);
	}
	void opOpAssign(string op)(Point rhs) shared	{
        this = this.opBinary!op(rhs);
	}
	void opOpAssign(string op)(real rhs)
	{
        this = this.opBinary!op(rhs); 
	}
	void opOpAssign(string op)(real rhs) shared
	{
	    this = this.opBinary!op(rhs);
	}
	Point opBinary(string op)(Point rhs)
	{
	    mixin("return Point(this.x " ~ op ~ " rhs.x, this.y " ~ op ~ " rhs.y, this.z " ~ op ~ " rhs.z);");
	}
	Point opBinary(string op)(shared Point rhs) shared
	{
	    mixin("return cast(shared(Point))Point(this.x " ~ op ~ " rhs.x, this.y " ~ op ~ " rhs.y, this.z " ~ op ~ " rhs.z);");
	}
	Point opBinary(string op)(real rhs)
	{
	    mixin("return Point(this.x " ~ op ~ "rhs, this.y " ~ op ~ "rhs, this.z " ~ op ~ "rhs);");
	}
	Point opBinary(string op)(real rhs) shared
	{
	    mixin("return cast(shared(Point))Point(this.x " ~ op ~ "rhs, this.y " ~ op ~ "rhs, this.z " ~ op ~ "rhs);");
	}
}
/**Struct for representing a face of a skeleton that is made out of lines.*/
public struct Face	{ //Face(of a 3D shape) structure...
	///Array of all the lines in a face.
	Line[] lines;
	///The center of the face.
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
	this(Line[] lines)
	{
	   this.lines = lines.dup;
	   this.center = find(Skeleton([this]));
	}
	this(Line[] lines) shared
	{
	    this.lines = cast(shared(Line[]))(cast(Line[])lines).dup;
		this.center = cast(shared(Point))find(cast(Skeleton)Skeleton(cast(Face[])[this]));
	}
}
/**Struct for representing a 3D skeleton.*/
public struct Skeleton	{ //Skeleton of a 3D structure...
	///Array of the faces that make up the skeleton.
	Face[] faces;
	///The centroid of the skeleton.
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
	this(Face[] faces)
	{
	    this.faces = faces.dup;
		this.center = find(this);
	}
	this(shared(Face)[] faces) shared
	{
	    this.faces = faces.dup;
		this.center = cast(shared(Point))find(cast(Skeleton)this);
	}
		
}

package Point find(Skeleton skele)
{
    Point x = Point(0,0,0);
	ulong count = 0;
    foreach(i; skele.faces)
	{
	    foreach(j; i.lines)
		{
		    foreach(k; j.mid_points)
			{
			    ++count;
                x += k;
			}
			count += 2;
            x += j.start;
			x += j.stop;
		}
	}
	x /= count;
	return x;
}		

/**Struct for representing a line composed of at least a starting point and an end point.
*/
public struct Line	{ //Line struct...
	///Array of all points that are not the start or end points.
	Point[] mid_points;
	///The start point of the line..
	Point start;
	///The end point of the line.
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