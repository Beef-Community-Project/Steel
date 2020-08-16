using System;
using System.IO;

namespace SteelEngine
{
	extension SteelPath
	{
		public static void GetEditorUserFolder(String relativePath, String target, bool create = false)
		{
			var path = scope String();
			Path.InternalCombine(path, "Editor", relativePath);
			GetUserFolder(path, target, create);
		}

		public static void GetEditorUserFile(String relativePath, String target, bool create = false)
		{
			var path = scope String();
			Path.InternalCombine(path, "Editor", relativePath);
			GetUserFile(path, target, create);
		}
	}
}
