using System;
using System.IO;

namespace SteelEngine
{
	extension SteelPath
	{
		public static void GetEditorUserPath(String target, params String[] components)
		{
			var newComponents = new String[components.Count + 1];
			newComponents[0] = "Editor";
			components.CopyTo(newComponents, 0, 1, components.Count);
			GetUserPath(target, params newComponents);
			delete newComponents;
		}

		public static void GetEditorSamplePath(String target, params String[] components)
		{
			var newComponents = new String[components.Count + 2];
			newComponents[0] = ContentDirectory;
			newComponents[1] = "Samples";
			components.CopyTo(newComponents, 0, 2, components.Count);
			Path.InternalCombine(target, params newComponents);
			delete newComponents;
		}
	}
}
