using System;
using System.Collections;

namespace SteelEngine.Console
{
	class GameConsole
	{
		const int HISTORY_SIZE = 50;

		private Dictionary<StringView, CVar> _cvars = new Dictionary<StringView, CVar>() ~ delete _;
		private Queue<String> _enqueuedCommands = new Queue<String>() ~ delete _;

		public CommandHistory History = new CommandHistory(HISTORY_SIZE) ~ delete _;

		protected bool _cvarCheatsEnabled = false;
		protected float _cvarWaitTime = 0;
		protected int _cvarWaitFrames = 0;
		
		public LogLevel LogLevel { get; set; }

		public this()
		{
			RegisterCVar("sv.cheats", "Enable execution of commands with Cheat flag.", ref _cvarCheatsEnabled);
			RegisterCVar("wait.frames", "Wait number of frames before continuing execution of commands.", ref _cvarWaitFrames);
			RegisterCVar("wait.seconds", "Wait number of real time seconds before continuing execution of commands.", ref _cvarWaitTime);


			RegisterCommand("echo", "", new (cmd, line, args) =>
		    {
				if (line.Length <= 4)
					return false;

				let cmdNameLength = cmd.Name.Length + 1;
				let str = StringView(line, cmdNameLength, line.Length - cmdNameLength);
				if (!str.IsEmpty)
					Log.Info(str);

				return true;
		    });

			RegisterCommand("help", "Show list of variables and commands", new (cmd, line, args) =>
			{
				StringView filter = default;
				if(args.Length >= 1)
				{
					filter = args[0];
				}

				for(let v in _cvars)
				{
					Log.Info("{0} - {1}", v.key, v.value.Help);
				}

				return true;
			});
		}

		public ~this()
		{
		 	for (let cvar in _cvars.Values)
				delete cvar;
		}	

		protected mixin CheckCVarRegistered(StringView name)
		{
			if (_cvars.TryGetValue(name, let cvar))
			{
				Log.Warning("CVar '{0}' already registered!", name);
				return cvar;
			}
		}

		public CVar RegisterCVar(StringView name, StringView help, ref bool varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleVar<bool>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCVar(StringView name, StringView help, ref int32 varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleVar<int32>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCVar(StringView name, StringView help, ref int64 varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleVar<int64>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCVar(StringView name, StringView help, ref float varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleVar<float>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCVar(StringView name, StringView help, ref String varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleVar<String>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCVar<TEnum>(StringView name, StringView help, ref TEnum varRef, CVarFlags flags = .None, OnCVarChange onChange = null) where TEnum : Enum
		{
			CheckCVarRegistered!(name);
			let cvar = new EnumConsoleVar<TEnum>(name, help, &varRef, flags, onChange);
			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterCommand(StringView name, StringView help, OnCmdExecute onExecute, CVarFlags flags = .None)
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleCommand(name, help, onExecute , flags);
			return _cvars[cvar.Name] = cvar;
		}

		public bool UnregisterCVar(StringView name)
		{
			if (_cvars.GetAndRemove(name) case .Ok(let val))
			{
				return true;
			}
			return false;
		}

		public bool UnregisterCVar(CVar cvar)
		{
			return UnregisterCVar(cvar.Name);
		}

		public CVar GetCVar(StringView name)
		{
			return _cvars.GetValueOrDefault(name);
		}

		public void Execute(StringView cmdLine)
		{
			int i, start;
			start = i = 0;

			List<StringView> tokens = scope .();
			
			while (ConsoleLineParser.Tokenize(cmdLine, ref i, ref start, tokens))
			{
				System.Diagnostics.Debug.Assert(!tokens.IsEmpty);
				StringView command = .(cmdLine, start, i - start);
				ExecuteLineTokens(command, .(tokens.Ptr, tokens.Count));
			}
		}

		protected void ExecuteLineTokens(StringView line, Span<StringView> tokens)
		{
			let cmdName = tokens[0];
			if (_cvars.TryGetValue(cmdName, let cvar))
			{
				if (tokens.Length > 1 && tokens[1] == "?")
				{
					String buffer = scope .();
					cvar.GetValueString(buffer);
					if (buffer.IsEmpty)
						Log.Info("{0} - '{1}'", cvar.Name, cvar.Help);
					else
						Log.Info("{0} {1} - '{2}'", cvar.Name, buffer, cvar.Help);

					return;
				}
				
				let result = cvar.Execute(line, .(tokens.Ptr+1, tokens.Length-1));
				if (!result)
				{
					Log.Error("Error occurred while executing '{0}'", cmdName);
				}
			}
			else
			{
				Log.Error("Couldn't find cvar named '{0}'", cmdName);
			}
		}

		protected void AddHistory(StringView cmdLine)
		{
			History.Add(cmdLine);
		}

		public void Enqueue(StringView cmdLine)
		{
			AddHistory(cmdLine);
			EnqueueNoHistory(cmdLine);
		}

		public void EnqueueNoHistory(StringView cmdLine)
		{
			_enqueuedCommands.Enqueue(new .(cmdLine));
		}

		public void Update()
		{
			let dt = Time.DeltaTimeUnscaled;
			if (_cvarWaitTime > 0) {
				_cvarWaitTime -= dt;
				return;
			}

			if (_cvarWaitFrames > 0) {
				_cvarWaitFrames--;
				return;
			}

			while(!(_cvarWaitTime > 0 || _cvarWaitFrames > 0) && _enqueuedCommands.Count > 0)
			{
				let line = _enqueuedCommands.Dequeue();
				Execute(line);
				delete line;
			}
		}
	}
}
