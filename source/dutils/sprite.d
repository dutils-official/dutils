/*sprite.d by Ruby The Roobster*/
/*Version 1.0.0 Release*/
/*Last Update: 08/23/2021*/
/*Module for sprites in the D Programming Language 2.0*/
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
module dutils.sprite;
public import dutils.skeleton : Point;
/**This data structure represents colors in the RGBA format.*/
public struct Color	{
	///'R' value of the color.
	ubyte r = 0;
	///'G' value of the color.
	ubyte g = 0;
	///'B' value of the color.
	ubyte b = 0;
	///'A' value of the color.
	ubyte a = 255;
	void opAssign(Color rhs)	{
		this.r = rhs.r;
		this.g = rhs.g;
		this.b = rhs.b;
		this.a = rhs.a;
	}
}
/**This data structure represents a sprite that would be painted over a face from dutils:skeleton*/
public struct Sprite	{
	///The array of colors that are used within the Sprite.
	Color[] colors;
	///A two-demensional array of the points corresponding to each color.
	Point[][] points;
	invariant()	{
		assert(colors.length == points.length, "Assertion failure: Sprite.colors.length and Sprite.points.length must always be equal...");
	}
	void opAssign(Sprite rhs)	{
		this.colors.length = rhs.colors.length;
		this.points.length = rhs.points.length;
		foreach(i;0 .. this.colors.length)	{
			this.colors[i] = rhs.colors[i];
		}
		foreach(i;0 .. this.points.length)	{
			this.points[i].length = rhs.points[i].length;
			foreach(j;0 .. this.points[i].length)	{
				this.points[i][j] = rhs.points[i][j];
			}
		}
	}
}

  /**ReadSpriteFromFile reads a file in .spr format and outputs a new 'Sprite" object from it.
  Params:
  filename =		The name of the file to read the sprite from.
  Returns:  A new 'Sprite' object interpreted from the file.*/
public Sprite ReadSpriteFromFile(immutable(char)[] filename)	{ //Reads a sprite in my made up .spr format(trash, why does this even exist)
	ubyte[] ftext;
	Color[] colors;
	Point[][] points;
	import std.file;
	ftext = cast(ubyte[])read(filename);
	for(uint i = 0;i < ftext.length;i++)	{ //Parse the file...
		long main;
		short exp;
		uint x = 0;
		++colors.length;
		++points.length;
		colors[x].r = ftext[i]; //Set r color...
		++i;
		colors[x].g = ftext[i];
		++i;
		colors[x].b = ftext[i];
		++i;
		colors[x].a = ftext[i];
		++i;
		ubyte tempcolor = ftext[i];
		++i;
		long temp;
		for(ubyte j = 0;j < tempcolor; ++j)	{
			posfunc(ftext, main, exp, temp, i, j, points , x);
		}
	}
	return Sprite(colors, points);
}
	
package void posfunc(const ubyte[] ftext, ref long main, ref short exp, ref long temp, ref uint i, const ubyte j, ref Point[][] points, ref uint x)	{
	++points[x].length;
	foreach(z;0 .. 3)	{
		short shift = 56;
		main = ftext[i];
		main <<= shift;
		++i;
		shift -= 8;
		while(shift >= 0)	{
			temp = ftext[i];
			main = (main <= (-0)) ? (main - temp) : (main + temp);
			++i;
			shift -= 8;
		}
		exp = ftext[i];
		exp <<= 8;	
		++i;
		exp += ftext[i];
		++i;
		switch(z)	{
			case 0:
				points[x][j].x = (main * 10^^exp);
				break;
			case 1:
				points[x][j].y = (main * 10^^exp);
				break;
			case 2:
				points[x][j].z = (main * 10^^exp);
				break;
			default:
				assert(false); //bruh...
		}		}
}
