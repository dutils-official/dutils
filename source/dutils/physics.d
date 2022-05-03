/*physics.d by Ruby The Roobster*/
/*Version 1.0.0 release*/
/*Module for basic physics in the D Programming Language 2.0*/
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
/**Date: November 8, 2021*/
/** License: GPL-3.0*/

///NOTICE: THIS CODE OBVIOUSLY SUCKS.  IT WILL BE DELETED AND REPLACED WITH SOMETHING ACTUALLY USUABLE.

module dutils.physics;
version(DLL)
{
	
}
else
{
	public import dutils.skeleton;

	///Struct for representing gravity.
	public struct Gravity
	{
		/** The axis which the gravity pulls toward.*/ Axis axis = Axis.y;
		/** The strength per frame of the gravity. */ real strength = 0;
	}

	///Enumeration for representing an axis.
	public enum Axis { /**The x-axis.*/ x, /**The y-axis.*/y, /**The z-axis.*/ z}
	///Enumeration for representing a plane.
	public enum Plane { /**Plane xy*/ xy, /**Plane xz*/ xz, /**Plane zy*/ zy}

	package mixin template __mov__general__(string func)
	{
		void __mov__general__(real accdec = 0, Gravity gravity = Gravity(Axis.y, 0))
		{
			import core.thread;
			Point moveby;
			bool b = false;
			auto ori = tomove;
				debug import std.stdio : writeln;
			if(speed > 1 || speed < -1)
			{
				moveby.x = moveto.x / speed;
				moveby.y = moveto.y / speed;
				moveby.z = moveto.z / speed;
				b = true;
			}
			else
			{
				moveby.x = moveto.x * speed;
				moveby.y = moveto.y * speed;
				moveby.z = moveto.z * speed;
			}
			while(!((tomove.center.x > moveto.x && moveto.x > 0) ^ (tomove.center.x < moveto.x && moveto.x < 0)))
			{
				static if(func[0] == 'a')
				{
					speed += accdec;
					if(b)
					{
						moveby.x = moveto.x / speed;
						moveby.y = moveto.y / speed;
						moveby.z = moveto.z / speed;
					}
					else
					{
						moveby.x = moveto.x * speed;
						moveby.y = moveto.y * speed;
						moveby.z = moveto.z * speed;
					}
				}
				else static if(func[0] == 'd')
				{
					speed -= accdec;
					if(b)
					{
						moveby.x = moveto.x / speed;
						moveby.y = moveto.y / speed;
						moveby.z = moveto.z / speed;
					}
					else
					{
						moveby.x = moveto.x * speed;
						moveby.y = moveto.y * speed;
						moveby.z = moveto.z * speed;
					}
				}
				else
				{
				}
				foreach(i;tomove.faces)
				{
					foreach(k;i.lines)
					{
						foreach(j;k.mid_points)
						{
							j += moveby;
						}
						k.start += moveby;
						k.stop += moveby;
					}
					i.center += moveby;
				}
				tomove.center += moveby;
				Thread.sleep(dur!"msecs"(tbf));
				static if(func[0] == 'a')
				{
					speed += accdec;
				}
				else static if(func[0] == 'd')
				{
					speed -= accdec;
				}
				else
				{
				}
			}
			foreach(i;ori.faces)
			{
				foreach(j;i.lines)	
				{
					foreach(k;j.mid_points)
					{
						k += moveto;
					}
					j.start += moveto;
					j.stop += moveto;
				}
				i.center += moveto;
			}
			ori.center += moveto;
			tomove = ori;
		}
	}

	  /**move moves all the points in a skeleton to a specified point with a specified time gap between moving the points.
	  Params:
		moveto =	A point specifying the total amount to move along each axis.
		tbf =	The time in miliseconds between 'frames'(a frame is one section of moving points before waiting a bit).  This gives an illusion of continuous motion.
		tomove =	The skeleton being moved.
		speed =	The speed at which to move the points.
	  Returns:
	  none*/
	pragma(inline, true) public void move(Point moveto, uint tbf, ref shared Skeleton tomove, real speed)
	{
		mixin __mov__general__!"n";
		__mov__general__();
	}

	  /**accMove moves all the points in a skeleton to a specified point with a specified time gap between movements all while accelerating the speed.
	  Params:
		moveto = 	A point specifying the total amount to move along each axis.
		tbf = 	The time in miliseconds between 'frames'(a frame is one section of moving points before waiting a bit).  This gives an illusion of continuous motion.
		tomove = 	The skeleton being moved.
		speed  = 	The original speed at which the skeleton moves.
		accdec = 	The amount to increment the speed by each frame.
	  Returns: none*/
	pragma(inline, true) public void accMove(Point moveto, uint tbf, shared ref Skeleton tomove, real speed, real accdec = 0)
	{
		mixin __mov__general__!"a";
		__mov__general__(accdec);
	}

	  /**decMove moves all the points in a skeleton to a specified point with a specified time gap between movements all while deaccelerating the speed.
	  Params:
		moveto = 	A point specifying the total amount to move along each axis.
		tbf = 	The time in miliseconds between 'frames'(a frame is one section of moving points before waiting a bit).  This gives an illusion of continuous motion.
		tomove = 	The skeleton being moved.
		speed  = 	The original speed at which the skeleton moves.
		accdec = 	The amount to decrement the speed by each frame.
	   Returns: none*/
	pragma(inline) public void decMove(Point moveto, uint tbf, shared ref Skeleton tomove, real speed, real accdec = 0)
	{
		mixin __mov__general__!"d";
		__mov__general__(accdec);
	}

	///Collision is a structure representing if a collision happened, and the object collided with.
	public struct Collision
	{
		///True if the collision actually occured.
		bool collided;
		///The skeleton collided with.
		shared Skeleton hitby;
	}

	  /**detectCollision takes a skeleton, a wait time, and an array of skeletons, and detects collisions, returning true if so.
	  Params:
			towatch =    A shared array of skeletons that the functions dectects collisions against.
			skele =     A skeleton that the function dectects collisions against the array of skeletons with.
			time =     The number of miliseconds to wait before exiting.  Infinete when set to real.infinity.
	   Returns:
	   A collision structure.
	  */
	public Collision detectCollision(shared Skeleton[] towatch, shared Skeleton skele, in real time = 0)
		in	{
			auto a = cast(ulong)time;
			assert(a == time || time == real.infinity,"Parameter time must always be a whole number or infinity!");
		}
		do	{
			mixin find!(["x", "y", "z"]);
			import std.datetime.stopwatch;
			auto sw = StopWatch(AutoStart.no);
			sw.start();
			scope(exit) sw.stop();
			while(true)
			{
				foreach(i;towatch)
				{
					foreach(j;i.faces)
					{
						foreach(k;j.lines)
						{
							foreach(l;k.mid_points)
							{
								foreach(m;skele.faces)
								{
									foreach(n;m.lines)
									{
										for(uint o; o < n.mid_points.length+1; o++)
										{
												
										pragma(inline, true) bool switcho(Point toswitch)
										{
											switch(o)
											{
												default:
													if(o == n.mid_points.length)
													{
														find([n.mid_points[o-1], n.stop]);
														return Collision(true, i).collided;
													}
													else
													{
														find([n.mid_points[o-1], n.mid_points[o]]);
													}
													if(toswitch.x <= highx && toswitch.x >= lowx && toswitch.y <= highy && toswitch.y >= lowy && toswitch.z <= highz && toswitch.z >= lowz)
													{
														return Collision(true, i).collided;
													}
													break;
													case 0:
													find([n.start, n.mid_points[o]]);
													if(toswitch.x <= highx && toswitch.x >= lowx && toswitch.y <= highy && toswitch.y >= lowy && toswitch.z <= highz && toswitch.z >= lowz)
													{
														return Collision(true, i).collided;
													}
												}
												assert(false, "Hidden function switcho has a bug, file an issue.");
										}
											if(switcho(l))
												return Collision(true, i);
											if(switcho(k.start))
												return Collision(true, i);
											if(switcho(k.stop))
												return Collision(true, i);
										}
									}
								}
							}
						}
					}
				}
				if(!(sw.peek.total!"msecs" <= time) && time != real.infinity)
					break;
			}
			return Collision(false, skele);
		}

	package mixin template find(string[] tofind)
	{
		static foreach(i; tofind)	{
			mixin("real high" ~ i ~ ";");
			mixin("real low" ~ i ~ ";");
		}
		void find(Point[2] tof)
		{
			static foreach(i; tofind)
			{
				mixin("high" ~ i ~ " = tof[0]." ~ i ~ " >= tof[1]." ~ i ~ " ? tof[0]." ~ i ~ " : tof[1]." ~ i ~ ";");
				mixin("low" ~ i ~ " = tof[0]." ~ i ~ " <= tof[1]." ~ i ~ " ? tof[0]." ~ i ~ " : tof[1]." ~ i ~ ";");
			}
		}
	}

	/**affectByGravity affects a skeleton by a specified gravity struct.  Send any integer to the thread containing the function to terminate it.
	Params:
	towatch =    A shared array of skeletons that is used for collision checking.
	skele =    A shared skeleton that is affected by gravity itself.
	tbf =  The wait time between frames in miliseconds, operations not included.  Set to at least 1, as the function spends 1 milisecond waiting for messages.
	gravity =    A gravity struct that gives the axis and strength specifications.
	Returns: none.*/
	pragma(inline, true) public void affectByGravity(shared Skeleton[] towatch, ref shared Skeleton skele, in uint tbf, Gravity gravity)
	{
			import std.concurrency;
		import core.thread;
		import std.datetime;
		void __dumbswitchiepoo__dumb(ref shared Point l)
		{
			switch(gravity.axis)
			{
				case Axis.x:
						if((gravity.strength > 0 && l.x > 0) ^ (gravity.strength < 0 && l.x < 0) || detectCollision(towatch, skele, 0).collided)
							l.x = l.x - gravity.strength;
						break;
				case Axis.y:
					if((gravity.strength > 0 && l.y > 0) ^ (gravity.strength < 0 && l.y < 0) || detectCollision(towatch, skele, 0).collided)				
							l.y = l.y - gravity.strength;
					break;
				case Axis.z:
					if((gravity.strength > 0 && l.z > 0) ^ (gravity.strength < 0 && l.z < 0) || detectCollision(towatch, skele, 0).collided)
						l.z = l.z - gravity.strength;
					break;
				default:
					throw new Exception("An error obviously caused by a library developer has occured.  Please file an issue.");
			}
		}
		while(true)
		{
			if(receiveTimeout(dur!"msecs"(1), function void(int x) { }))
			{
			  break;
			}
			foreach(ref i;skele.faces)
			{
				foreach(ref j;i.lines)
				{
					foreach(ref k;j.mid_points)
					{
						__dumbswitchiepoo__dumb(k);
					}
					__dumbswitchiepoo__dumb(j.start);
					__dumbswitchiepoo__dumb(j.stop);
				}
				__dumbswitchiepoo__dumb(i.center);
			}
			__dumbswitchiepoo__dumb(skele.center);
			Thread.sleep(dur!"msecs"(tbf));
		}
	}

	/**Rotates a skeleton by an amount in radians in anamount of frames with a specifed time between frames.
	   Params:
		degrees =    The number of radians to rotate the Skeleton by.
		plane =    The plane to rotate the Skeleton on.
		frames =    The number of frames to rotate the Skeleton in.
		rate =    The amount of time in miliseconds to wait between processing each frame.
		skele =    The Skeleton to rotate.
	*/
	public void rotate(in real degrees, in Plane plane, in ulong frames, in ulong rate, ref shared Skeleton skele)
	{
		ulong fcounter = 0;
		assert(frames != 0); //Prevent division by 0.
		import std.math.algebraic : abs;
		import std.math.trigonometry : sin;
		import std.math.trigonometry: cos;
		import core.thread;
		bruh:
		switch(plane)
		{
			static foreach(a; ["xy", "xz", "zy"])
			{
				mixin("case Plane." ~ a ~ ":");
				while(fcounter <= frames)
				{
					foreach(ref i; skele.faces)
					{
						foreach(ref j; i.lines)
						{
							foreach(ref k; j.mid_points)
							{
								mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - k." ~ [a[0]] ~ "));"); //Define the radius of the circle of rotation.
								//Do the rotation thingy.
								mixin("k." ~ [a[0]] ~ " = (cos(degrees/frames) * radius) + skele.center." ~ [a[0]] ~ ";");
								//As above
								mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - k." ~ [a[1]] ~ "));");
								mixin("k." ~ [a[1]] ~ " = (sin(degrees/frames) * radius) + skele.center." ~ [a[1]] ~ ";");
							}
							//Rinse and Repeat!
							mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - j.start." ~ [a[0]] ~ "));");
							mixin("j.start." ~ [a[0]] ~ " = (cos(degrees/frames) * radius) + skele.center." ~ [a[0]] ~ ";");
							mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - j.start." ~ [a[1]] ~ "));");
							mixin("j.start." ~ [a[1]] ~ " = (sin(degrees/frames) * radius) + skele.center." ~ [a[1]] ~ ";");
							mixin("radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - j.stop." ~ [a[0]] ~ "));");
							mixin("j.stop." ~ [a[0]] ~ " = (cos(degrees/frames) * radius) + skele.center." ~ [a[0]] ~ ";");
							mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - j.stop." ~ [a[1]] ~ "));");
							mixin("j.stop." ~ [a[1]] ~ " = (sin(degrees/frames) * radius) + skele.center." ~ [a[1]] ~ ";");
						}
						mixin("real radius = abs(cast(real)(skele.center." ~ [a[0]] ~ " - i.center." ~ [a[0]] ~ "));");
						mixin("i.center." ~ [a[0]] ~ " = (cos(degrees/frames) * radius) + skele.center." ~ [a[0]] ~ ";");
						mixin("radius = abs(cast(real)(skele.center." ~ [a[1]] ~ " - i.center." ~ [a[1]] ~ "));");
						mixin("i.center." ~ [a[1]] ~ " = (sin(degrees/frames) * radius) + skele.center." ~ [a[1]] ~ ";");
					}
					Thread.sleep(dur!"msecs"(rate)); //Time between frames.
					++fcounter;
				}
				mixin("break bruh;");
			}
			default:
				throw new Exception("Invalid Plane, somehow.  Either I screwed up or you did.  If you didn't touch the code, open an issue.");
		}
	}
}
