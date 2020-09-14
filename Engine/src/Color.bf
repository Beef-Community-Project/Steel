using SteelEngine.Math;

namespace SteelEngine
{
	public struct Color
	{
		public float r, g, b, a;

		public this() : this(1, 1, 1, 1) {}


		public this(float r, float g, float b) : this(r, g, b, 1) {}

		public this(float r, float g, float b, float a)
		{
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}

		public Color Normalized => .(r / 255, b / 255, g / 255, a / 255);

		public static Color Black => .(0, 0, 0, 1);
		public static Color Blue => .(0, 0, 1, 1);
		public static Color Cyan => .(0, 1, 1, 1);
		public static Color Gray => .(0.5f, 0.5f, 0.5f, 1);
		public static Color Green => .(0, 1, 0, 1);
		public static Color Grey => Gray;
		public static Color Magenta => .(1, 0, 1, 1);
		public static Color Red => .(1, 0, 0, 1);
		public static Color Transparent => .(0, 0, 0, 0);
		public static Color White => .(1, 1, 1, 1);
		public static Color Yellow => .(1, 0.92f, 0.016f, 1);

		public static implicit operator Vector4(Self self)
		{
			return .(self.r, self.g, self.b, self.a);
		}

		public static implicit operator Self(Vector4 vec)
		{
			return .(vec.x, vec.y, vec.z, vec.w);
		}
	}
}
