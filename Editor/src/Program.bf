using System;
using JetFistGames.Toml;

namespace SteelEditor
{
	class Program
	{
		public static int Main(String[] args)
		{
			/*var serialized = scope String();
			var style = imgui_beef.ImGui.Style();
			TomlSerializer.Write(style, serialized);

			Console.WriteLine(serialized);*/

			var editor = new Editor();
			editor.Run();
			delete editor;

			return 0;
		}
	}
}