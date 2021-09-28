/*skeleton.d by Ruby The Roobster*/
/*Version 1.0 Release*/
/*Module for representing skeletons in the D Programming Language 2.0*/

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
