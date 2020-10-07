using System;
using System.Collections;
using System.IO;

namespace SteelEngine
{
	public static class SteelPath
	{
		public static String UserDirectory = new .() ~ delete _;
		public static String ContentDirectory = new .() ~ delete _;
		public static String EngineInstallationPath = new .() ~ delete _;

		public static this()
		{
			Dictionary<String, String> envVars = new .();
			Environment.GetEnvironmentVariables(envVars);

			if (envVars.ContainsKey("APPDATA"))
				Path.InternalCombine(UserDirectory, envVars["APPDATA"], "Steel");

			DeleteDictionaryAndKeysAndItems!(envVars);

#if DEBUG
			Directory.GetCurrentDirectory(EngineInstallationPath);
#else
			var executablePath = scope String();
			Environment.GetExecutableFilePath(executablePath);
			Path.GetDirectoryPath(executablePath, EngineInstallationPath);
#endif
		}

		public static void SetContentDirectory()
		{
			/*ContentDirectory.Clear();

#if DEBUG
			Directory.GetCurrentDirectory(ContentDirectory);
#else
			var executablePath = scope String();
			Environment.GetExecutableFilePath(executablePath);
			Path.GetDirectoryPath(executablePath, ContentDirectory);
#endif

			Log.Trace("Content Directory: {}", ContentDirectory);*/
		}

		public static void GetUserPath(String target, params String[] components)
		{
			String[] newComponents = new String[components.Count + 1];
			newComponents[0] = UserDirectory;
			components.CopyTo(newComponents, 0, 1, components.Count);
			Path.InternalCombine(target, params newComponents);
			delete newComponents;
		}

		public static void GetGamePath(String target, params String[] components)
		{
			String[] newComponents = new String[components.Count + 1];
			newComponents[0] = UserDirectory;
			components.CopyTo(newComponents, 0, 1, components.Count);
			Path.InternalCombine(target, params newComponents);
		}
	}
}
