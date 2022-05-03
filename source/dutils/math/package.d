module dutils.math;

version(DLL)
{
	export import dutils.math.core;
}
else
{
	public import dutils.math.core;
}