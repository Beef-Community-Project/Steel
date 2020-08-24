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
		public static mixin Deg2Rad(float deg)
		{
			deg / 180 * System.Math.PI_f
		}
		public static mixin Rad2Deg(float rad)
		{
			rad / System.Math.PI_d * 180
		}

		public static mixin Deg2Rad(double deg)
		{
			deg / 180 * System.Math.PI_f
		}
		public static mixin Rad2Deg(double rad)
		{
			rad / System.Math.PI_d * 180
		}
	}
}
