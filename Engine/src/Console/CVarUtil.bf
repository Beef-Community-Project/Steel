using System;

namespace SteelEngine.Console
{
	static class CVarUtil
	{
		public static bool TryParse(StringView strval, ref bool result)
		{
			switch(strval)
			{
			case "true", "True", "TRUE", "1":
				result = true;
			case "false", "False", "FALSE", "0":
				result = false;
			}

			return false;
		}

		public static bool TryParse(StringView strval, ref int32 result)
		{
			if (int32.Parse(strval) case .Ok(let val))
			{
				result = val;
				return true;
			}

			return false;
		}

		public static bool TryParse(StringView strval, ref int64 result)
		{
			if (int64.Parse(strval) case .Ok(let val))
			{
				result = val;
				return true;
			}

			return false;
		}

		public static bool TryParse(StringView strval, ref float result)
		{
			if (float.Parse(strval) case .Ok(let val))
			{
				result = val;
				return true;
			}

			return false;
		}

		public static bool TryParse(StringView strval, ref String result)
		{
			result.Clear();
			result.Append(strval);
			return true;
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
			return 0;
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
			return 0;
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
