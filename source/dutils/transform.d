module dutils.transform;

public import dutils.skeleton;

/**Move all the points in the skeleton instantenously by a specified amount on each axis.
   Params:
    moveby =    The point that specifies how much to move on each axis.
	skele =    The skeleton to move.
   Returns:
    none
*/
public void move(in Point moveby, shared ref Skeleton skele)
{
    foreach(ref i;skele.faces)
	{
	    foreach(ref j; i.lines)
		{
		    foreach(ref k; j.mid_points)
			{
			    k += moveby;
			}
			j.start += moveby;
			j.stop += moveby;
		}
		i.center += moveby;
	}
	skele.center += moveby;
}

public import dutils.physics : Axis;

/**Scale all the points in the skeleton along a specified axis by a specified amount.
   Params:
    scale =    The amount to scale by.
	axis =    The axis on which to scale the skeleton on.
	skele =    The skeleton to scale.
   Returns:
    none
*/
public void scale(in real scale, in Axis axis, ref shared Skeleton skele)
{
    bruh:
    switch(axis)
	{
	    static foreach(a; ["x","y","z"])
		{
		    import dutils.physics : Axis;
		    mixin("case Axis." ~ a ~ ":");
			foreach(ref i; skele.faces)
		    {
				foreach(ref j; i.lines)
				{
				    foreach(ref k; j.mid_points)
					{
					    mixin("k." ~ a ~ " = k." ~ a ~ " * scale;");
					}
					mixin("j.stop." ~ a ~ " = j.stop." ~ a ~ " * scale;");
					mixin("j.start." ~ a ~ " = j.start." ~ a ~ " * scale;");
				}
				mixin("i.center." ~ a ~ " = i.center." ~ a ~ " * scale;");
			}
			mixin("break bruh;");
		}
		default:
		    throw new Exception("Invalid axis, somehow.  Either you tampered with the library, or I screwed up.  If you haven't tampered with this library, please file an issue.");
	}
}