/*init.d by Ruby The Roobster*/
/*Version 0.3.5 Release*/
/*Last Updated: 08/10/2021*/
/*Module for menus in the D Programming Language 2.0*/
module dutils.init;

class cMenu	{ //Menu to be displayed on console.
	private:
		string[] opt;
		uint function()[] handlers;
	public:
		this(inout(string[]) opt, uint function()[] handlers)
			in	{
				assert(opt.length == handlers.length, "Error: The amount of options must equal the amount of handlers.");
			}

			do	{
				this.opt.length = opt.length;
				this.handlers.length = handlers.length;
				for(int i; i < opt.length; i++)	{
					this.opt[i] = opt[i];
					this.handlers[i] = handlers[i];
				}
			}

		void displayandreadMenu()	{ //Displays the menu and handles any input
			import std.stdio;
			import std.string;
			string input;
			uint x = 1;
			for(uint i = 0; i < this.opt.length; i++)	{
				writefln("%d: %s", i+1, this.opt[i]);
			}

			input = strip(readln());
			for(uint i = 0; i < this.opt.length; i++)	{
				if(this.opt[i] == input)	{
					x = this.handlers[i]();
					break;
				}
			}

			if(x != 0)	{
				throw new Exception("Error: Invalid menu option.");
			}
		}
}

version(Windows)	{ //Graphics that uses Win32 API, so this only works on 32-bit Windows systems
	class winbMenu	{ //Menu that uses Win32 API to display itself as a set of buttons
	}

	class imgMenu	{ //Menu that uses WinGDI to display itself on a window, which allows for more button customization
	}
}

version(linux)	{ //Whishfull thinking: Implement same classes above but for Linux
}
