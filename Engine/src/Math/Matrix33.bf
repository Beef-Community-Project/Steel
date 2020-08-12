using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix33_t<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		public const let ROWS = 3;
		public const let COLUMNS = 3;
		public const let SIZE = ROWS * COLUMNS;

		public T[ROWS][COLUMNS] data2d;
		public T[SIZE] data;
		public Vector3_t<T>[COLUMNS] columns;

		public this()
		{
			this = default;
		}

		public this(T m00, T m01, T m02,
					T m10, T m11, T m12,
					T m20, T m21, T m22)
		{
			data = .(m00, m01, m02,
					m10, m11, m12,
					m20, m21, m22);
		}

		public this(Vector3_t<T> c1, Vector3_t<T> c2, Vector3_t<T> c3)
		{
			columns = .(c1, c2, c3);
		}

		public T m00 { [Inline] get { return data[0]; } [Inline] set mut { data[0] = value; } }
		public T m01 { [Inline] get { return data[1]; } [Inline] set mut { data[1] = value; } }
		public T m02 { [Inline] get { return data[2]; } [Inline] set mut { data[2] = value; } }

		public T m10 { [Inline] get { return data[3]; } [Inline] set mut { data[3] = value; } }
		public T m11 { [Inline] get { return data[4]; } [Inline] set mut { data[4] = value; } }
		public T m12 { [Inline] get { return data[5]; } [Inline] set mut { data[5] = value; } }

		public T m20 { [Inline] get { return data[6]; } [Inline] set mut { data[6] = value; } }
		public T m21 { [Inline] get { return data[7]; } [Inline] set mut { data[7] = value; } }
		public T m22 { [Inline] get { return data[8]; } [Inline] set mut { data[8] = value; } }

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

		public static Self Zero => .(0,0,0,
									 0,0,0,
									 0,0,0);

		public static Self Identity => .(1,0,0,
										 0,1,0,
										 0,0,1);


		public T Determinant
		{
			get
			{
				return m00 * (m11*m22 - m12*m21) - m01 * (m10*m22 - m12*m20) + m02 * (m10*m21 - m11*m20); 
			}
		}

		public Self Inverse
		{
			get
			{
				// Find determinant of matrix.
				T sub11 = data[4] * data[8] - data[5] * data[7], sub12 = -data[1] * data[8] + data[2] * data[7],
				sub13 = data[1] * data[5] - data[2] * data[4];
				T determinant = data[0] * sub11 + data[3] * sub12 + data[6] * sub13;

				// Find determinants of 2x2 submatrices for the elements of the inverse.
				Self inverse = .(sub11, sub12, sub13,
								data[6] * data[5] - data[3] * data[8], data[0] * data[8] - data[6] * data[2],
								data[3] * data[2] - data[0] * data[5], data[3] * data[7] - data[6] * data[4],
								data[6] * data[1] - data[0] * data[7], data[0] * data[4] - data[3] * data[1]);
				inverse *= (T)1 / determinant;
				return inverse;
			}	
		}

		public void Transpose() mut
		{
			Vector3_t<T>[COLUMNS] tmp = ?;
			tmp[0] = .(this[0, 0], this[0, 1], this[0, 2]);
			tmp[1] = .(this[1, 0], this[1, 1], this[1, 2]);
			tmp[2] = .(this[2, 0], this[2, 1], this[2, 2]);
			columns = tmp;
		}

		public Self Transposed
		{
			[Inline]
			get
			{
				Self tmp = this;
				return tmp..Transpose();
			}
		}

		public static Self operator+(Self lv, Self rv)
		{
			Self tmp = lv;
			tmp.columns[0] += rv.columns[0];
			tmp.columns[1] += rv.columns[1];
			tmp.columns[2] += rv.columns[2];
			return tmp;
		}

		[Commutable]
		public static Self operator+(Self lv, T rv)
		{
			Self tmp = lv;
			tmp.columns[0] += rv;
			tmp.columns[1] += rv;
			tmp.columns[2] += rv;
			return tmp;
		}

		public static Self operator-(Self lv, Self rv)
		{
			Self tmp = lv;
			tmp.columns[0] -= rv.columns[0];
			tmp.columns[1] -= rv.columns[1];
			tmp.columns[2] -= rv.columns[2];
			return tmp;
		}

		[Commutable]
		public static Self operator-(Self lv, T rv)
		{
			Self tmp = lv;
			tmp.columns[0] -= rv;
			tmp.columns[1] -= rv;
			tmp.columns[2] -= rv;
			return tmp;
		}

		public static Self operator*(Self lv, Self rv)
		{
			Self tmp = ?;
			{
			  Vector3_t<T> row = .(lv[0], lv[3], lv[6]);
			  tmp[0] = Vector3_t<T>.DotProduct(rv.Column(0), row);
			  tmp[3] = Vector3_t<T>.DotProduct(rv.Column(1), row);
			  tmp[6] = Vector3_t<T>.DotProduct(rv.Column(2), row);
			}
			{
				Vector3_t<T> row = .(lv[1], lv[4], lv[7]);
				tmp[1] = Vector3_t<T>.DotProduct(rv.Column(0), row);
				tmp[4] = Vector3_t<T>.DotProduct(rv.Column(1), row);
				tmp[7] = Vector3_t<T>.DotProduct(rv.Column(2), row);
			}
			{
				Vector3_t<T> row = .(lv[2], lv[5], lv[8]);
				tmp[2] = Vector3_t<T>.DotProduct(rv.Column(0), row);
				tmp[5] = Vector3_t<T>.DotProduct(rv.Column(1), row);
				tmp[8] = Vector3_t<T>.DotProduct(rv.Column(2), row);
			}
			return tmp;
		}

		[Commutable]
		public static Self operator*(Self lv, T rv)
		{
			Self tmp = lv;
			tmp.columns[0] *= rv;
			tmp.columns[1] *= rv;
			tmp.columns[2] *= rv;
			return tmp;
		}

		public static Self operator/(Self lv, T rv)
		{
			return lv * (1 / rv);
		}
	}
}
