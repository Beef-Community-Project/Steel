using System;
using System.Collections;

namespace SteelEngine.Console
{
	public static class EnumUtils<TEnum> where TEnum : Enum
	{
		private static HashSet<int> _values ~ delete _;

		static this()
		{
			_values = new .();

			let type = typeof(TEnum);
			for (var field in type.GetFields())
			{
				_values.Add(field.[Friend]mFieldData.[Friend]mData);
			}
		}

		public static bool HasValue(int iVal)
		{
			return _values.Contains(iVal);
		}
	}
}
