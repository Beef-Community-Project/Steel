using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix34_t<T>
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		public const let ROWS = 3;
		public const let COLUMNS = 4;
		public const let SIZE = ROWS * COLUMNS;

		public T[ROWS][COLUMNS] data2d;
		public T[SIZE] data;
		public Vector3_t<T>[COLUMNS] columns;

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

		public this(Matrix33_t<T> m)
		{
			data = .(m[0],m[1],m[2], 1,
					m[3],m[4],m[5],	1,
					m[6],m[7],m[8], 1);
		}	

		public T m00 { [Inline] get { return data[0]; } [Inline] set mut { data[0] = value; } }
		public T m01 { [Inline] get { return data[1]; } [Inline] set mut { data[1] = value; } }
		public T m02 { [Inline] get { return data[2]; } [Inline] set mut { data[2] = value; } }
		public T m03 { [Inline] get { return data[3]; } [Inline] set mut { data[3] = value; } }

		public T m10 { [Inline] get { return data[3]; } [Inline] set mut { data[4] = value; } }
		public T m11 { [Inline] get { return data[4]; } [Inline] set mut { data[5] = value; } }
		public T m12 { [Inline] get { return data[5]; } [Inline] set mut { data[6] = value; } }
		public T m13 { [Inline] get { return data[7]; } [Inline] set mut { data[7] = value; } }

		public T m20 { [Inline] get { return data[6]; } [Inline] set mut { data[8] = value; } }
		public T m21 { [Inline] get { return data[7]; } [Inline] set mut { data[9] = value; } }
		public T m22 { [Inline] get { return data[8]; } [Inline] set mut { data[10] = value; } }
		public T m23 { [Inline] get { return data[11]; } [Inline] set mut { data[11] = value; } }

		public T this[int i]
		{
			[Inline] get { return data[i]; }
			[Inline] set mut { data[i] = value; }
		}

		public T this[int row, int column]
		{
			[Inline] get { return data2d[column][row]; }
			[Inline] set mut { data2d[column][row] = value; }
		}

		public Vector3_t<T> Column(int i)
		{
			return columns[i];
		}
	}
}
