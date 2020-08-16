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

		public abstract int64 GetValueInt32();
		public abstract int64 GetValueInt64();
		public abstract float GetValueFloat() ;
		public abstract void GetValueString(String buffer) ;

		public abstract bool Execute(StringView line, Span<StringView> args);

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
		protected OnCVarChange _onChange ~ delete _;

		public override int64 GetValueInt32() { return CVarUtil.GetValueInt32(*_value); }
		public override int64 GetValueInt64() { return CVarUtil.GetValueInt64(*_value); }
		public override float GetValueFloat() { return CVarUtil.GetValueFloat(*_value); }
		public override void GetValueString(String buffer) { (*_value).ToString(buffer); }

		public override bool Execute(StringView line, Span<StringView> args)
		{
			if (args.Length >= 1 && CVarUtil.TryParse(args[0], ref *_value))
			{
				_onChange?.Invoke(this);
				return true;
			}

			return false;
		}

		public this(StringView name, StringView help, T* val, CVarFlags flags, OnCVarChange onChange) : base(name, help, flags)
		{
			_value = val;
			_onChange = _onChange;
		}
	}

	
	class EnumConsoleVar<TEnum> : CVar where TEnum: Enum
	{
		protected TEnum* _value;
		protected OnCVarChange _onChange ~ delete _;

		public override int64 GetValueInt32() { return (*_value); }
		public override int64 GetValueInt64() { return (*_value); }
		public override float GetValueFloat() { return (int)(*_value); }
		public override void GetValueString(String buffer) { (*_value).ToString(buffer); }

		public override bool Execute(StringView line, Span<StringView> args)
		{
			if (args.Length >= 1)
			{
				if (TEnum.Parse<TEnum>(args[0], true) case .Ok(let val))
				{
					*_value = val;
					_onChange?.Invoke(this);
					return true;
				}
				if((int64.Parse(args[0]) case .Ok(var iVal)) && EnumUtils<TEnum>.HasValue(iVal))
				{
					*_value = *(TEnum*)&iVal;
					_onChange?.Invoke(this);
					return true;
				}
				
			}

			return false;
		}

		public this(StringView name, StringView help, TEnum* val, CVarFlags flags, OnCVarChange onChange) : base(name, help, flags)
		{
			_value = val;
			_onChange = _onChange;
		}
	}

	public delegate bool OnCmdExecute(ConsoleCommand cmd, StringView line, Span<StringView> args);

	class ConsoleCommand : CVar
	{
		protected OnCmdExecute _onExecute ~ delete _;

		public override int64 GetValueInt32() => 0;
		public override int64 GetValueInt64() => 0;
		public override float GetValueFloat() => 0;
		public override void GetValueString(String buffer) {}

		public override bool Execute(StringView line, Span<StringView> args)
		{
			if (_onExecute == null)
				return false;

			return _onExecute.Invoke(this, line, args);
		}

		public this(StringView name, StringView help, OnCmdExecute onExec, CVarFlags flags) : base(name, help, flags)
		{
			_onExecute = onExec;
		}
	}
}
