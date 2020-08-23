using System;
using System.Collections;
using System.IO;

namespace SteelEngine
{
	public static class SteelPath
	{
		public static String UserDirectory = new .() ~ delete _;

		public static this()
		{
			Dictionary<String, String> envVars = new .();
			Environment.GetEnvironmentVariables(envVars);

			if (envVars.ContainsKey("APPDATA"))
				Path.InternalCombine(UserDirectory, envVars["APPDATA"], "Steel");

			DeleteDictionaryAndKeysAndItems!(envVars);
		}

		public static void GetUserFolder(String relativePath, String target, bool create = false)
		{
			Path.InternalCombine(target, UserDirectory, relativePath);

			if (create && !Directory.Exists(target))
			{
				if (Directory.CreateDirectory(target) case .Err(let err))
					Log.Error("Failed to create user directory: {}", err);
			}
		}

		public static void GetUserFile(String relativePath, String target, bool create = false)
		{
			Path.InternalCombine(target, UserDirectory, relativePath);

			var dir = scope String();
			Path.GetDirectoryPath(target, dir);
			if (create && !Directory.Exists(dir))
				Directory.CreateDirectory(dir);

			if (create && !File.Exists(target))
			{
				if (File.WriteAllText(target, "") case .Err(let err))
					Log.Error("Failed to create user directory: {}", err);
			}
		}
	}
}
