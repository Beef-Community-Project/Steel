using System.Collections;
using imgui_beef;

namespace System
{
	extension Type
	{
		public void GetShortName(String buffer)
		{
			var fullName = scope String();
			GetFullName(fullName);
			var parts = scope List<StringView>(fullName.Split('.'));
			buffer.Append(parts.Back);
		}
	}
}

namespace System.Reflection
{
	extension FieldInfo
	{
		public void GetName(String buffer)
		{
			buffer.Append(GetName());
		}

		public StringView GetName()
		{
			if (Name.StartsWith("prop__"))
				return .(Name, 6);
			else
				return Name;
		}
	}
}

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
}

namespace SteelEngine
{
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
