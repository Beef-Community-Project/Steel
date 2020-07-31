using System;
using SteelEngine;

namespace BasicSteelGame
{
	class BasicGameApp : Application
	{
		public override void OnInit()
		{
			base.OnInit();
		}

		public override void OnCleanup()
		{
			base.OnCleanup();
		}
	}

	class Program
	{
		public static int Main(String[] args)
		{
			var app = scope BasicGameApp();
			app.Run();

			return 0;
		}
	}
}