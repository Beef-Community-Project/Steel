using System;

namespace SteelEngine.Console
{
	static class CVarUtil
	{
		public static bool TryParse(CVar cvar, Span<StringView> args, ref bool result, out bool didChange)
		{
			let currentVal = result;

			String lowercase = scope String(args[0])..ToLower();

			switch (lowercase)
			{
			case "true", "1":
				result = true;
			case "false", "0":
				result = false;
			default:
				switch (int.Parse(lowercase))
				{
				case .Err:
					return false;
				case .Ok(let val):
					result = val != 0;
				}
			}
			didChange = result != currentVal;
			return true;
		}

		public static bool TryParse(CVar cvar, Span<StringView> args, ref int32 result, out bool didChange)
		{
			let currentVal = result;
			if (int32.Parse(args[0]) case .Ok(let val))
			{
				result = val;
				didChange = result != currentVal; 
				return true;
			}

			didChange = false;
			return false;
		}

		public static bool TryParse(CVar cvar, Span<StringView> args, ref int64 result, out bool didChange)
		{
			let currentVal = result;
			if (int64.Parse(args[0]) case .Ok(let val))
			{
				result = val;
				didChange = result != currentVal;
				return true;
			}

			didChange = false;
			return false;
		}

		public static bool TryParse(CVar cvar, Span<StringView> args, ref float result, out bool didChange)
		{
			let currentVal = result;
			if (float.Parse(args[0]) case .Ok(let val))
			{
				result = val;
				didChange = result != currentVal;
				return true;
			}

			didChange = false;
			return false;
		}

		public static bool TryParse(CVar cvar, Span<StringView> args, ref String result, out bool didChange)
		{
			didChange = result != args[0];
			result.Clear();
			result.Append(args[0]);
			return true;
		}

		public static bool TryParse<TEnum>(CVar cvar, Span<StringView> args, ref TEnum result, out bool didChange) where TEnum : Enum
		{
			let currentVal = result;

			if (TEnum.Parse<TEnum>(args[0], true) case .Ok(let val))
			{
				result = val;
				didChange = result != currentVal;
				return true;
			}
			if ((int64.Parse(args[0]) case .Ok(var iVal)) && (cvar.HasFlags(.Flags) || EnumUtils<TEnum>.HasValue(iVal)))
			{
				result = *(TEnum*)&iVal;
				didChange = result != currentVal;
				return true;
			}

			didChange = false;
			return false;
		}

		public static int32 GetValueInt32(bool* val)
		{
			return *val ? 1 : 0;
		}

		public static int32 GetValueInt32(int32* val)
		{
			return *val;
		}

		public static int32 GetValueInt32(int64* val)
		{
			return (int32)*val;
		}

		public static int32 GetValueInt32(float* val)
		{
			return (int32)*val;
		}

		public static int32 GetValueInt32(String* val)
		{
			if (int32.Parse(*val) case .Ok(let res))
			{
				return res;
			}
			return (int32)(*val).GetHashCode();
		}

		public static int32 GetValueInt64(bool* val)
		{
			return *val ? 1 : 0;
		}

		public static int64 GetValueInt64(int32* val)
		{
			return (int64)*val;
		}

		public static int64 GetValueInt64(int64* val)
		{
			return *val;
		}

		public static int64 GetValueInt64(float* val)
		{
			return (int64)*val;
		}

		public static int64 GetValueInt64(String* val)
		{
			if (int64.Parse(*val) case .Ok(let res))
			{
				return res;
			}
			return (*val).GetHashCode();
		}

		public static int32 GetValueFloat(bool* val)
		{
			return *val ? 1 : 0;
		}

		public static float GetValueFloat(int32* val)
		{
			return (float)*val;
		}

		public static float GetValueFloat(int64* val)
		{
			return (float)*val;
		}

		public static float GetValueFloat(float* val)
		{
			return *val;
		}

		public static float GetValueFloat(String* val)
		{
			if (float.Parse(*val) case .Ok(let res))
			{
				return res;
			}
			return 0;
		}

	}
}
