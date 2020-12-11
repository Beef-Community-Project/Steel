using ImGui;

namespace SteelEngine
{
	extension Color
	{
		public static implicit operator Self(ImGui.Vec4 vec)
		{
			return .(vec.x, vec.y, vec.z, vec.w);
		}

		public static implicit operator ImGui.Vec4(Self self)
		{
			return .(self.r, self.g, self.b, self.a);
		}
	}

	extension Vector4<T>
	{
		public static implicit operator ImGui.Vec4(Self self) where float : operator explicit T
		{
			return .((float) self.x, (float) self.y, (float) self.z, (float) self.w);
		}
	}

	extension Vector2<T>
	{
		public static implicit operator ImGui.Vec2(Self self) where float : operator explicit T
		{
			return .((float) self.x, (float) self.y);
		}
	}
}
