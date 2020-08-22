using System;

namespace SteelEditor
{
	class Program
	{
		public static int Main(String[] args)
		{
			var editor = new Editor();
			editor.Run();
			delete editor;

			return 0;
		}
	}
}