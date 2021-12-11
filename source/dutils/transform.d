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