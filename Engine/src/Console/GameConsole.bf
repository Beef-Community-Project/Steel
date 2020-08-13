using System;
using System.Collections;
using System.IO;
using SteelEngine.Console;

namespace SteelEngine
{
	class GameConsole
	{
		struct ConfigVarValue : IDisposable
		{
			public String line;
			public StringView[] args;

			public void Dispose()
			{
				delete line;
				delete args;
			}
		}

		public struct LineEntry : IDisposable
		{
			public LogLevel level;
			public String message;

			public void Dispose()
			{
				delete message;
			}
		}

		static Self _instance;
		public static Self Instance => _instance;

		Dictionary<StringView, CVar> _cvars = new Dictionary<StringView, CVar>() ~ delete _;
		Dictionary<StringView, OnCVarChange> _cvarChangedCallbacks = new Dictionary<StringView, OnCVarChange>() ~ delete _;
		Dictionary<StringView, ConfigVarValue> _configVars = new Dictionary<StringView, ConfigVarValue>() ~ delete _;
		Queue<String> _enqueuedCommands = new Queue<String>() ~ delete _;
		CommandsHistory _history ~ delete _;
		int32 _historySize = 100;

		int _maxLines = -1;
		List<LineEntry> _lines = new List<LineEntry>() ~ delete _;

		public CommandsHistory History => _history;

		bool _cvarCheatsEnabled = false;
		float _cvarWaitTime = 0;
		int _cvarWaitFrames = 0;
		
		public LogLevel logLevel = .Info;

		bool _opened = false;
		public bool IsOpen => _opened;

		public this()
		{
			_instance = this;
		}

		public ~this()
		{
		 	for (let cvar in _cvars.Values)
				delete cvar;

			for (let cb in _cvarChangedCallbacks.Values)
				delete cb;

			for (let line in _lines)
				line.Dispose();

			for (let val in _configVars.Values)
				val.Dispose();
		}

		public void Initialize(Span<String> configFiles)
		{
			Log.AddCallback(new (level, str) =>
			{
				PrintLine(level, str);
			});

			for (var file in configFiles)
			{
				if (LoadConfigFile(file) case .Err(let err))
				{
					Log.Error("Couldn't open configuration file {0} ({1})", file, err);
				}
			}

			RegisterVariable("console.historysize", "Size of commands history.", ref _historySize, .Config, new (cvar) => { _historySize = Math.Max(1, _historySize); History.Resize(_historySize); } );
			_history = new CommandsHistory(_historySize);

			RegisterVariable("console.maxlines", "Maximum lines console output can store (-1 for unlimited)", ref _maxLines, .Config, new (cvar) => ResizeOutput() );
			RegisterVariable("console.loglevel", "Minimal level message need to be to be logged into console", ref logLevel, .Config);
			RegisterVariable("sv.cheats", "Enable execution of commands with Cheat flag.", ref _cvarCheatsEnabled);
			RegisterVariable("wait.frames", "Wait number of frames before continuing execution of commands.", ref _cvarWaitFrames);
			RegisterVariable("wait.seconds", "Wait number of real time seconds before continuing execution of commands.", ref _cvarWaitTime);

			RegisterCommand("echo", "Print message", new (line, args) =>
			{
				PrintInfo(line);
			});

			RegisterCommand("help", "Show list of variables and commands", new (line, args) =>
			{
				StringView filter = args.Length > 0 ? args[0] : default;

				String buffer = scope .();

				for (let cvar in _cvars.Values)
				{
					if (!cvar.HasFlags(.Hidden) && (filter.IsEmpty || cvar.Name.Contains(filter)))
					{
						buffer.Append("    ");
						buffer.Append(cvar.Name);
						if (!cvar.Help.IsEmpty)
							buffer.AppendF(" - {0}", cvar.Help);
						buffer.Append("\n");
					}
				}

				PrintInfo(buffer);
			});

			RegisterCommand("exec", "Execute file", new (line, args) =>
			{
				if (args.Length > 0 && ExecuteFile(args[0]) case .Err(let err))
				{
					PrintErrorF("Couldn't execute file {0} ({1}).", args[0], err);
				}
			});
	
			RegisterCommand("cls", "Clear console", new () =>
			{
				Clear();
			});
		}

		public void Open()
		{
			_opened = true;
		}

		public void Close()
		{
			_opened = false;
		}	

		public void Toggle()
		{
			_opened = !_opened;
		}

		public void Clear()
		{
			for (let l in _lines)
				l.Dispose();

			_lines.Clear();
		}

		protected void ResizeOutput()
		{
			if (_maxLines < 0)
				return;

			for (int i = _maxLines; i < _lines.Count; i++)
			{
				_lines[i].Dispose();
			}
		}

		protected void PrintLine(LogLevel logLevel, StringView message)
		{
			LineEntry entry = LineEntry() { level = logLevel };
			if (_maxLines < 0 || _lines.Count < _maxLines)
			{
				entry.message = new String(message);
			}
			else
			{
				entry.message = _lines.PopFront().message..Set(message);
			}

			_lines.Add(entry);
		}

		protected void PrintLineF(LogLevel logLevel, StringView format, params Object[] args)
		{
			String buffer = scope .();
			buffer.AppendF(format, params args);
			PrintLine(logLevel, buffer);
		}

		public void PrintInfo(StringView message) => PrintLine(.Info, message);
		public void PrintInfoF(StringView format, params Object[] args) => PrintLineF(.Info, format, params args);
		public void PrintWarning(StringView message) => PrintLine(.Warning, message);
		public void PrintWarningF(StringView format, params Object[] args) => PrintLineF(.Warning, format, params args);
		public void PrintError(StringView message) => PrintLine(.Warning, message);
		public void PrintErrorF(StringView format, params Object[] args) => PrintLineF(.Warning, format, params args);

		protected mixin CheckCVarRegistered(StringView name)
		{
			if (_cvars.TryGetValue(name, let cvar))
			{
				Log.Warning("CVar {0} already registered!", name);
				return cvar;
			}
		}

		protected void LoadConfigVarValue(CVar cvar)
		{
			if (_configVars.GetAndRemove(cvar.Name) case .Ok(var val))
			{
				if (cvar.Execute(val.value.line, val.value.args) case .Ok)
				{
					cvar.AddFlags(.WasInConfig);
				}
				else
				{
					Log.Error("Error occurred while setting configuration variable. Can't set value of {0} to {1}", cvar.Name, val.value.args[0]);
				}
				val.value.Dispose();
			} 
		}

		protected CVar RegisterCVar(CVar cvar, OnCVarChange onChange)
		{
			if (cvar.HasFlags(.Config))
				LoadConfigVarValue(cvar);

			if (onChange != null)
				_cvarChangedCallbacks[cvar.Name] = onChange;

			return _cvars[cvar.Name] = cvar;
		}

		public CVar RegisterVariable(StringView name, StringView help, ref bool varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new ConsoleVar<bool>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterVariable(StringView name, StringView help, ref int32 varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new ConsoleVar<int32>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterVariable(StringView name, StringView help, ref int64 varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new ConsoleVar<int64>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterVariable(StringView name, StringView help, ref float varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new ConsoleVar<float>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterVariable(StringView name, StringView help, ref String varRef, CVarFlags flags = .None, OnCVarChange onChange = null)
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new ConsoleVar<String>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterVariable<TEnum>(StringView name, StringView help, ref TEnum varRef, CVarFlags flags = .None, OnCVarChange onChange = null) where TEnum : Enum
		{
			CheckCVarRegistered!(name);
			return RegisterCVar(new EnumConsoleVar<TEnum>(name, help, &varRef, flags), onChange);
		}

		public CVar RegisterCommand(StringView name, StringView help, OnCmdExecute onExecute, CVarFlags flags = .None) => RegisterCommand<OnCmdExecute>(name, help, onExecute, flags);
		public CVar RegisterCommand(StringView name, StringView help, OnCmdExecuteNoArgs onExecute, CVarFlags flags = .None) => RegisterCommand<OnCmdExecuteNoArgs>(name, help, onExecute, flags);
		public CVar RegisterCommand(StringView name, StringView help, OnCmdExecuteLineArgs onExecute, CVarFlags flags = .None) => RegisterCommand<OnCmdExecuteLineArgs>(name, help, onExecute, flags);

		protected CVar RegisterCommand<TDelegate>(StringView name, StringView help, TDelegate onExecute, CVarFlags flags) where TDelegate : Delegate
		{
			CheckCVarRegistered!(name);
			let cvar = new ConsoleCommand<TDelegate>(name, help, onExecute, flags);
			return _cvars[cvar.Name] = cvar;
		}

		public bool UnregisterCVar(StringView name)
		{
			if (_cvars.GetAndRemove(name) case .Ok(let val))
			{
				if ( _cvarChangedCallbacks.TryGetValue(name, let cb))
					delete cb;

				delete val.value;
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
				StringView command = .(cmdLine, start, i - start);
				ExecuteLineTokens(command, .(tokens.Ptr, tokens.Count));
			}
		}

		protected void ExecuteLineTokens(StringView line, Span<StringView> tokens)
		{
			let cmdName = tokens[0];
			if (_cvars.TryGetValue(cmdName, let cvar) && !cvar.HasFlags(.Hidden))
			{
				// If CVar is not command and there are no arguments specified just print its value
				if (tokens.Length == 1 && !cvar.IsCommand)
				{
					String buffer = scope .();
					cvar.ToString(buffer);
					PrintInfo(buffer);

					return;
				}

				// If the command is entered with ? parameter show its description
				if (tokens.Length > 1 && tokens[1] == "?")
				{
					String buffer = scope .();
					buffer.AppendF("{0} ", cvar.Name);
					let strVal = cvar.GetValueString(buffer);
					if (!strVal.IsEmpty)
						buffer.Append(' ');
					
					if (!cvar.Help.IsEmpty)
						buffer.AppendF("- {0}", cvar.Help);

					PrintInfo(buffer);
					return;
				}

				if (cvar.HasFlags(.Cheat) && !_cvarCheatsEnabled)
				{
					PrintErrorF("{0} can only be executed when cheats are enabled.", cvar.Name);
					return;
				}

				StringView strArgs = line;
				if (tokens.Length > 1)
				{
					strArgs = .(line, tokens[1].Ptr - line.Ptr);
				}	

				let result = cvar.Execute(strArgs, .(tokens.Ptr+1, tokens.Length-1));
				if (result case .Ok(let changed))
				{
					if ((changed || cvar.HasFlags(.AlwaysOnChange)) && _cvarChangedCallbacks.TryGetValue(cvar.Name, let callback))
					{
						callback(cvar);
					}
				}
				else
				{
					PrintErrorF("Error occurred while executing {0}.", cmdName);
				}
			}
			else
			{
				PrintErrorF("Couldn't find {0} in registered cvars.", cmdName);
			}
		}

		protected void AddHistory(StringView cmdLine)
		{
			_history.Add(cmdLine);
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
			if (_cvarWaitTime > 0) {
				_cvarWaitTime -= Time.DeltaTimeUnscaled;
				return;
			}

			if (_cvarWaitFrames > 0) {
				_cvarWaitFrames--;
				return;
			}

			while (!(_cvarWaitTime > 0 || _cvarWaitFrames > 0) && _enqueuedCommands.Count > 0)
			{
				let line = _enqueuedCommands.Dequeue();
				Execute(line);
				delete line;
			}
		}

		public Result<void, FileOpenError> ExecuteFile(StringView path)
		{
			StreamReader reader = scope .();
			if (reader.Open(path) case .Err(let err))
				return .Err(err);

			String buffer = scope .();
			while (reader.ReadLine(buffer) case .Ok)
			{
				EnqueueNoHistory(buffer);
			}

			return .Ok;
		}

		private Result<void, FileOpenError> LoadConfigFile(StringView path)
		{
			StreamReader reader = scope .();
			if (reader.Open(path) case .Err(let err))
				return .Err(err);

			String buffer = scope .();
			List<StringView> tokens = scope .();

			String line = new .();

			while (reader.ReadLine(buffer) case .Ok)
			{
				int i = 0;
				int start = 0;
				
				while (ConsoleLineParser.Tokenize(buffer, ref i, ref start, tokens, line))
				{
					if (tokens.Count < 2)
						continue;

					let name = tokens[0];
					if (_configVars.GetAndRemove(name) case .Ok(let val))
					{
						val.value.Dispose();
					}

					StringView[] args = new StringView[tokens.Count-1];
					tokens.CopyTo(1, args, 0, tokens.Count-1);
					_configVars.Add(name, ConfigVarValue()
					{
						line = line,
						args = args
					});
					line = new .();
					
				}

				buffer.Clear();
			}

			delete line;
			return .Ok;
		}

		public void GetCVars(StringView prefix, List<CVar> cvars, int maxCount = -1)
		{
			for (let cvar in _cvars)
			{
				if (prefix.IsEmpty)
					cvars.Add(cvar.value);
				else if (cvar.key.StartsWith(prefix))
					cvars.Add(cvar.value);

				if (maxCount > 0 && cvars.Count >= maxCount)
					break;
			}
		}
	}
}
