/*sprite.d by Ruby The Roobster*/
/*Version 0.3.5 Release*/
/*Last Update: 08/23/2021*/
/*Module for sprites in the D Programming Language 2.0*/
module dutils.sprite;
import skeleton : Point;

	public struct Color	{
		ubyte r = 0;
		ubyte g = 0;
		ubyte b = 0;
		ubyte a = 255;
		void opAssign(Color rhs)	{
			this.r = rhs.r;
			this.g = rhs.g;
			this.b = rhs.b;
			this.a = rhs.a;
		}
	}

	public struct Sprite	{
		Color[] colors;
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
		package void ChangeLengths(uint c)	{ //Change both lengths so invariant doesn't get triggered...
			this.colors.length = c;
			this.points.length = c;
		}
	}
	
	public Sprite ReadSpriteFromFile(immutable(char)[] filename)	{ //Reads a sprite in my made up .spr format(trash, why does this even exist)
		ubyte[] ftext;
		Color[] colors;
		Point[][] points;
		import std.file;
		uint i = 0;
		ftext = cast(ubyte[])read(filename);
		while(i < ftext.length)	{ //Parse the file...
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
			}
		}
	}