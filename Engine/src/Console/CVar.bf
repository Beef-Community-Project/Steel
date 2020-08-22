using System;
using System.Collections;

namespace SteelEngine.Console
{
	abstract class CVar
	{
		protected String _name ~ delete _;
		protected String _help ~ delete _;

		public StringView Name => _name;
		public StringView Help => _help;
		public CVarFlags Flags { get; protected set; }

		public bool HasFlags(CVarFlags flags) => Flags.HasFlag(flags); 
		public void AddFlags(CVarFlags flags) => Flags |= flags;
		public void RemoveFlags(CVarFlags flags) => Flags &= ~flags;

		public abstract Type Type { get; }

		public abstract int32 GetValueInt32();
		public abstract int64 GetValueInt64();
		public abstract float GetValueFloat() ;
		public abstract StringView GetValueString(String buffer) ;

		public abstract Result<bool> Execute(StringView strArgs, Span<StringView> args);

		public virtual bool IsCommand => false;

		protected this(StringView name, StringView help, CVarFlags flags)
		{
			_name = new .(name);
			_help = new .(help);
			Flags = flags;
		}
	}

	public delegate void OnCVarChange(CVar cvar);

	class ConsoleVar<T> : CVar where T : var
	{
		protected T* _value;

		public ref T Value => *_value;

		public override Type Type => typeof(T);

		public override int32 GetValueInt32() { return CVarUtil.GetValueInt32(*_value); }
		public override int64 GetValueInt64() { return CVarUtil.GetValueInt64(*_value); }
		public override float GetValueFloat() { return CVarUtil.GetValueFloat(*_value); }
		public override StringView GetValueString(String buffer)
		{
			let start = buffer.Length;
			(*_value).ToString(buffer);
			return .(buffer, start);
		}

		public override Result<bool> Execute(StringView strArgs, Span<StringView> args)
		{
			bool changed;
			if (args.Length >= 1 && CVarUtil.TryParse(this, args, ref *_value, out changed))
			{ 
				return changed;
			}

			return .Err;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("{0} ", Name);
			GetValueString(strBuffer);
		}

		public this(StringView name, StringView help, T* val, CVarFlags flags) : base(name, help, flags)
		{
			_value = val;
		}
	}

	
	class EnumConsoleVar<TEnum> : ConsoleVar<TEnum> where TEnum : Enum
	{
		public override int32 GetValueInt32() { return (int32) (*_value); }
		public override int64 GetValueInt64() { return (int32) (*_value); }
		public override float GetValueFloat() { return (int)(*_value); }


		public this(StringView name, StringView help, TEnum* val, CVarFlags flags) : base(name, help, val, flags)
		{
			
		}
	}

	public delegate bool OnCmdExecute(CVar cmd, StringView line, Span<StringView> args);
	public delegate void OnCmdExecuteNoArgs();
	public delegate void OnCmdExecuteLineArgs(StringView line, Span<StringView> args);

	class ConsoleCommand<OnExecute> : CVar where OnExecute : Delegate
	{
		protected OnExecute _onExecute ~ delete _;

		public override Type Type => typeof(OnExecute);

		public override int32 GetValueInt32() => 0;
		public override int64 GetValueInt64() => 0;
		public override float GetValueFloat() => 0;
		public override StringView GetValueString(String buffer) => default;

		public override bool IsCommand => true;

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("{0}", Name);
		}

		public this(StringView name, StringView help, OnExecute onExec, CVarFlags flags) : base(name, help, flags)
		{
			_onExecute = onExec;
		}
	}

	extension ConsoleCommand<OnExecute> where OnExecute : OnCmdExecute
	{
		public override Result<bool> Execute(StringView strArgs, Span<StringView> args)
		{
			if (_onExecute == null)
				return .Err;

			return _onExecute(this, strArgs, args) ? .Ok(false) : .Err;
		}
	}

	extension ConsoleCommand<OnExecute> where OnExecute : OnCmdExecuteNoArgs
	{
		public override Result<bool> Execute(StringView strArgs, Span<StringView> args)
		{
			if (_onExecute == null)
				return .Err;

			_onExecute();
			return false;
		}
	}

	extension ConsoleCommand<OnExecute> where OnExecute : OnCmdExecuteLineArgs
	{
		public override Result<bool> Execute(StringView strArgs, Span<StringView> args)
		{
			if (_onExecute == null)
				return .Err;

			_onExecute(strArgs, args);
			return false;
		}
	}

}
