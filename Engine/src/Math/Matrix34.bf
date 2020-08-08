using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix34_t<T> where T : var
	{
		public const let ROWS = 3;
		public const let COLUMNS = 4;
		public const let SIZE = ROWS * COLUMNS;

		public T[ROWS][COLUMNS] data2d;
		public T[SIZE] data;
		public Vector4_t<T>[ROWS] rows;

		public T m11 { [Inline] get { return data[0]; } [Inline] set mut { data[0] = value; } }
		public T m12 { [Inline] get { return data[1]; } [Inline] set mut { data[1] = value; } }
		public T m13 { [Inline] get { return data[2]; } [Inline] set mut { data[2] = value; } }
		public T m14 { [Inline] get { return data[3]; } [Inline] set mut { data[3] = value; } }

		public T m21 { [Inline] get { return data[4]; } [Inline] set mut { data[4] = value; } }
		public T m22 { [Inline] get { return data[5]; } [Inline] set mut { data[5] = value; } }
		public T m23 { [Inline] get { return data[6]; } [Inline] set mut { data[6] = value; } }
		public T m24 { [Inline] get { return data[7]; } [Inline] set mut { data[7] = value; } }

		public T m31 { [Inline] get { return data[8]; } [Inline] set mut { data[8] = value; } }
		public T m32 { [Inline] get { return data[9]; } [Inline] set mut { data[9] = value; } }
		public T m33 { [Inline] get { return data[10]; } [Inline] set mut { data[10] = value; } }
		public T m34 { [Inline] get { return data[11]; } [Inline] set mut { data[11] = value; } }

		public T this[int i]
		{
			[Inline] get { return data[i]; }
			[Inline] set mut { data[i] = value; }
		}

		public T this[int x, int y]
		{
			[Inline] get { return data2d[x][y]; }
			[Inline] set mut { data2d[x][y] = value; }
		}

		public Vector4_t<T> Row(int i)
		{
			return rows[i];
		}

		public this()
		{
			this = default;
		}

		public this(T m11, T m12, T m13, T m14,
					T m21, T m22, T m23, T m24,
					T m31, T m32, T m33, T m34)
		{
			data = .(m11, m12, m13, m14,
						m21, m22, m23, m24,
						m31, m32, m33, m34);
		}

		public this(T[SIZE] _data)
		{
			data = _data;
		}

		public this(T[ROWS][COLUMNS] _data)
		{
			data2d = _data;
		}

		public this(Matrix33_t<T> m)
		{
			data = .(m[0],m[1],m[2], 1,
					m[3],m[4],m[5],	1,
					m[6],m[7],m[8], 1);
		}	
	}
}
