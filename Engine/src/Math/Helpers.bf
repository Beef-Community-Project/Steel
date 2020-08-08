using System;

namespace SteelEngine.Math
{
	public class Helpers
	{
		public static void HashCombine(ref int seed, int _hash)
		{
			int hash = _hash;
			hash += 0x9e3779b9 + (seed << 6) + (seed >> 2);
			seed ^= hash;
		}
	}

	public static
	{
		static mixin Deg2Rad(var deg)
		{
			deg / 180 * System.Math.PI_d
		}
		static mixin Rad2Deg(var rad)
		{
			rad / System.Math.PI_d * 180
		}
	}
}
