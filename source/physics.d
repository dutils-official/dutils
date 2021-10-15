/*physics.d by Ruby The Roobster*/
/*Version 0.35 testing*/
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
/**Date: October 11, 2021*/
/** License: GPL-3.0*/
module dutils.physics;
public import dutils.skeleton;
/**
  * move moves all the points in a skeleton to a specified point with a specified time gap between moving the points.
  * Params:
  * moveto=	A point specifying the total amount to move along each axis.
  * tbf=	The time in miliseconds between 'frames'(a frame is one section of moving points before waiting a bit).  This gives an illusion of continuous motion.
  * tomove=	The skeleton being moved.
  * speed=	The speed at which to move the points.
  * Returns:
  * none
*/
public void move(Point moveto, uint tbf, ref Skeleton tomove, real speed)	{
	import core.thread;
	Point moveby;
	auto ori = tomove;
		debug import std.stdio : writeln;
	if(speed > 1 || speed < -1)	{
		moveby.x = moveto.x / speed;
		moveby.y = moveto.y / speed;
		moveby.z = moveto.z / speed;
	}
	else	{
		moveby.x = moveto.x * speed;
		moveby.y = moveto.y * speed;
		moveby.z = moveto.z * speed;
	}
	while(!((tomove.center.x > moveto.x && moveto.x > 0) ^ (tomove.center.x < moveto.x && moveto.x < 0)))	{
		foreach(i;tomove.faces)	{
			foreach(k;i.lines)	{
				foreach(j;k.mid_points)	{
					j += moveby;
				}
				k.start += moveby;
				k.stop += moveby;
			}
			i.center += moveby;
		}
		tomove.center += moveby;
		Thread.sleep(dur!"msecs"(tbf));
	}
	foreach(i;ori.faces)	{
		foreach(j;i.lines)	{
			foreach(k;j.mid_points)	{
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

public void accMove()	{
}

public void decMove()	{
}