using System;
namespace SteelEngine.Console
{
	class ExampleUsage
	{
		public static void Run()
		{
			GameConsole c = scope .();
			int32 x = 5;
			int64 q = 6;
			float f = 7;
			String s = scope .("sad");
			CVarFlags flags = .Cheat;

			String buffer = scope .();
			let xv = c.RegisterCVar("sv.int32", "", ref x)..GetValueString(buffer);
			let qv = c.RegisterCVar("sv.int64", "", ref q)..GetValueString(buffer);
			let fv = c.RegisterCVar("sv.float", "", ref f)..GetValueString(buffer);
			let sv = c.RegisterCVar("sv.string", "", ref s)..GetValueString(buffer);
			let flv = c.RegisterCVar("sv.enum", "", ref flags)..GetValueString(buffer);

			c.Execute("sv.int32 16; sv.float 14.1;");
			c.Execute("sv.string \"wowo dsjakdas\"; sv.float 14.1;");
			c.Execute("sv.string \"\";dasd");
			c.Execute("echo halo you beautiful person; echo second command?;");

			c.Enqueue("wait.seconds 1");

			String line = scope .();

			Time.[Friend]Initialize();

			while(true)
			{
				Time.[Friend]Update();

				line.Clear();
				Console.ReadLine(line);
				if (line == "quit")
					break;
				c.Enqueue(line);
				c.Update();
			}

			x = 10;
			q = 50;
			f = 14.1f;
			//s = "dasdadas";

			flags = .Config;

			StringView[1] asd = .("12");

			buffer.Append("  ");
			xv.GetValueString(buffer);
			qv.GetValueString(buffer);
			fv.GetValueString(buffer);
			sv.GetValueString(buffer);
			flv.GetValueString(buffer);
		}
	}
}
