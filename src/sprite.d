/*sprite.d by Ruby The Roobster*/
/*Version 0.3.5 Release*/
/*Last Update: 08/23/2021*/
/*Module for sprites in the D Programming Language 2.0*/
module dutils.sprite;
import skeleton : Point;

version(USE_BUILT_IN_SPRITES)	{ //Use built in sprites(garbage .spr format coded by me, that still needs an editor: Editor using GtKD for .spr comes out later this year, if I can get myself to do it)...
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
	
	public ubyte ReadSpriteFromFile(immutable(char)[] filename, ref Sprite dest)	{ //Reads a sprite in my made up .spr format(trash, why does this even exist)
		import std.stdio;
		File file = File(filename, "r");
		import std.string;
		import std.format;
		import std.conv : to;
		string buffer;
		bool first = true;
		long i = -1;
		uint j = 0;
		while(!file.eof())	{
			buffer = file.readln();
			buffer = strip(buffer);
			switch(buffer)	{
				case "RGB":
					i += 1;
					j = 0;
					dest.ChangeLengths(cast(uint)i+1);
					dest.points[cast(uint)i].length = 0;
					foreach(k;0 .. 2)	{
						buffer = file.readln(',');
						buffer = cast(string)parse(cast(char[])buffer);
						switch(k)	{
							case 0:
								dest.colors[cast(uint)i].r = to!ubyte(buffer);
								break;
							case 1:
								dest.colors[cast(uint)i].g = to!ubyte(buffer);
								break;
							default:
								break;
						}
					}
					buffer = file.readln();
					buffer = strip(buffer);
					dest.colors[cast(uint)i].b = to!ubyte(buffer);
					break;
				case "RGBA":
					i += 1;
					j = 0;
					dest.ChangeLengths(cast(uint)i+1);
					dest.points[cast(uint)i].length = 0;
					foreach(k;0 .. 3)	{
						buffer = file.readln(',');
						buffer = cast(string)parse(cast(char[])buffer);
						switch(k)	{
							case 0:
								dest.colors[cast(uint)i].r = to!ubyte(buffer);
								break;
							case 1:
								dest.colors[cast(uint)i].g = to!ubyte(buffer);
								break;
							case 2:
								dest.colors[cast(uint)i].b = to!ubyte(buffer);
								break;
							default:
								break;
						}
					}
					buffer = file.readln();
					buffer = strip(buffer);
					dest.colors[cast(uint)i].a = to!ubyte(buffer);
					break;
				case "POS":
					dest.points[cast(uint)i].length += 1;
					buffer = file.readln(',');
					buffer = cast(string)parse(cast(char[])buffer);
					dest.points[cast(uint)i][j].x = to!ushort(buffer);
					buffer = file.readln(',');
					buffer = cast(string)parse(cast(char[])buffer);
					dest.points[cast(uint)i][j].y = to!ushort(buffer);
					buffer = file.readln();
					buffer = strip(buffer);
					dest.points[cast(uint)i][j].z = to!ushort(buffer);
					j+=1;
					break;
				case "END":
					goto Close;
					break;
				default:
					throw new Exception(format("Invalid Statement: %s", buffer));
					break;
			}
		}
		Close:
		file.close();
		return 0;
		assert(0);
	}
	
	package char[] parse(char[] toparse)	{
		foreach(i;0 .. toparse.length)	{
			if(toparse[i] == ',')	{
				for(uint j = cast(uint)i;j < (toparse.length-1);j++)	{
					toparse[j] = toparse[j+1];
				}
				toparse.length-=1;
			}
		}
	return toparse;
	}
}

version(USE_OTHER_SPRITE)	{ //If the user wants to work with sprites their own way...
	public alias Sprite = uint function();
}

version(USE_FILE_SPRITE)	{  //If the user wants to read the sprites from a file and do it that way...
	public alias Sprite = wchar[];
}
