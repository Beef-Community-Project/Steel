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

	extension String
	{
		public void MakeSerializable()
		{
			Replace("\\", "\\\\");
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

namespace System.IO
{
	extension Directory
	{
		public static void Copy(StringView from, StringView to)
		{
			if (!Directory.Exists(from))
			{
				SteelEngine.Log.Error("Tried to copy non-existing directory: {}", from);
				return;
			}

			if (!Directory.Exists(to))
				Directory.CreateDirectory(to);

			var toStr = new String(to);

			var filePath = new String();
			var fileName = new String();
			var newFilePath = new String();
			for (var file in Directory.EnumerateFiles(from))
			{
				file.GetFilePath(filePath);
				file.GetFileName(fileName);

				Path.InternalCombine(newFilePath, toStr, fileName);

				File.Copy(filePath, newFilePath);

				filePath.Clear();
				fileName.Clear();
				newFilePath.Clear();
			}

			delete filePath;
			delete fileName;
			delete newFilePath;

			var dirPath = new String();
			var dirName = new String();
			var newDirPath = new String();
			
			for (var directory in Directory.EnumerateDirectories(from))
			{
				directory.GetFilePath(dirPath);
				directory.GetFileName(dirName);
				Path.InternalCombine(newDirPath, toStr, dirName);

				Copy(dirPath, newDirPath);

				dirPath.Clear();
				dirName.Clear();
				newDirPath.Clear();
			}
			
			delete dirPath;
			delete dirName;
			delete newDirPath;
			delete toStr;
		}

		public static List<String> GetFilesRecursively(StringView path)
		{
			var fileList = new List<String>();
			GetFilesRecursively(scope String(path), fileList);
			return fileList;
		}

		private static void GetFilesRecursively(String path, List<String> fileList)
		{
			for (var file in Directory.EnumerateFiles(path))
			{
				var filePath = new String();
				file.GetFilePath(filePath);
				fileList.Add(filePath);
			}

			var dirs = Directory.EnumerateDirectories(path);
			path.Clear();
			for (var dir in dirs)
			{
				dir.GetFilePath(path);
				GetFilesRecursively(path, fileList);
				path.Clear();
			}
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
