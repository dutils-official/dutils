import std.stdio;
import std.process;
void main()	{
	version(DigitalMars)	{
		immutable(char)[] extension = ".lib";
		immutable(char)[] objextension = ".obj";
		immutable(char)[] cmdline = "dmd -c -of=./obj/";
		immutable(char)[] libline = "lib -c ./lib/";
	}
	version(GNU)	{
		immutable(char)[] extension = ".a";
		immutable(char)[] objextension = ".o";
		immutable(char)[] cmdline = "gdc -c -o ./obj/";
		immutable(char)[] libline = "ar -crs -o ./lib/";
	}
	version(LDC)	{
		static assert(false, "LDC is not supported as a compiler, please use GDC or DMD instead.");
	}
	version(SDC)	{
		static assert(false, "SDC is not supported as a compiler, please use GDC or DMD instead.");
	}
	immutable(char)[][] ifiles = ["binom"];
	foreach(i;0 .. ifiles.length)	{ //Build the files into static libraries...
		char[] currcmdline;
		char[] currlibline;
		currcmdline = cmdline.dup;
		currlibline = libline.dup;
		foreach(j;0 .. ifiles[cast(uint)i].length)	{
			++currcmdline.length;
			currcmdline[cast(uint)currcmdline.length-1] = ifiles[cast(uint)i][cast(uint)j];
		}
		foreach(j;0 .. objextension.length)	{
			++currcmdline.length;
			currcmdline[cast(uint)currcmdline.length-1] = objextension[cast(uint)j];
		}
		++currcmdline.length;
		currcmdline[cast(uint)currcmdline.length-1] = ' ';
		currcmdline.length += 6;
		currcmdline[cast(uint)(currcmdline.length-6) .. $] = "./src/";
		foreach(j;0 .. ifiles[cast(uint)i].length)	{
			++currcmdline.length;
			currcmdline[cast(uint)currcmdline.length-1] = ifiles[cast(uint)i][cast(uint)j];
		}
		currcmdline.length += 2;
		currcmdline[cast(uint)currcmdline.length-2 .. $] = ".d";
		executeShell(currcmdline);
		foreach(j;0 .. ifiles[cast(uint)i].length)	{
			++currlibline.length;
			currlibline[cast(uint)currlibline.length-1] = ifiles[cast(uint)i][cast(uint)j];
		}
		foreach(j;0 .. extension.length)	{
			++currlibline.length;
			currlibline[cast(uint)currlibline.length-1] = extension[cast(uint)j];
		}
		++currlibline.length;
		currlibline[cast(uint)currlibline.length-1] = ' ';
		currlibline ~= "./obj/".dup;
		foreach(j;0 .. ifiles[cast(uint)i].length)	{
			++currlibline.length;
			currlibline[cast(uint)currlibline.length-1] = ifiles[cast(uint)i][cast(uint)j];
		}
		currlibline ~= objextension.dup;
		executeShell(currlibline);
	}
	//Abnormal libbuilding...
	string[] abnormal = [ "sprite" ];
	string[][2] versions = [ [ "USE_BUILT_IN_SPRITES", "ubfs" ] ];
	foreach(lib;0 .. cast(uint)abnormal.length)	{
		char[] currcmdline;
		char[] currlibline;
		currcmdline = cmdline.dup;
		currlibline = libline.dub;
		currcmdline ~= abnormal[lib];
		foreach(ver;0 .. cast(uint)versions[lib].length)	{
			if((ver % 2) != 0)	{
				currcmdline ~= versions[lib][ver];
			}
		}
		currcmdline ~= objextension;
		currcmdline ~= " ";
		version(DigitalMars)	{
			currcmdline ~= "-version=";
		}
		version(GDC)	{
			currcmdline ~= "--fversion=";
		}
		foreach(ver;0 .. cast(uint)versions[lib].length)	{
			if((ver % 2) == 0)	{
				currcmdline ~= versions[lib][ver];
			}
		}
		currcmdline ~= " ";
		currcmdline ~= ("./src/" ~ abnormal[lib] ~ ".d");
		executeShell(currcmdline); //Execute current command line...
		currlibline ~= abnormal[lib];
		foreach(ver;0 .. cast(uint)versions[lib].length)	{
			if((ver % 2) != 0)	{
				currlibline ~= versions[lib][ver];
			}
		}
		currlibline ~= extension;
		currlibline ~= (" ./obj/" ~ abnormal[lib]);
		foreach(ver;0 .. cast(uint)versions[lib].length)	{
			if((ver % 2) != 0)	{
				currlibline ~= versions[lib][ver];
			}
		}
		currlibline ~= objextension;
}