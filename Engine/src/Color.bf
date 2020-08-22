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

		public Color Black => .(0, 0, 0, 1);
		public Color Blue => .(0, 0, 1, 1);
		public Color Cyan => .(0, 1, 1, 1);
		public Color Gray => .(0.5f, 0.5f, 0.5f, 1);
		public Color Green => .(0, 1, 0, 1);
		public Color Grey => Gray;
		public Color Magenta => .(1, 0, 1, 1);
		public Color Red => .(1, 0, 0, 1);
		public Color Transparent => .(0, 0, 0, 0);
		public Color White => .(1, 1, 1, 1);
		public Color Yellow => .(1, 0.92f, 0.016f, 1);

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
