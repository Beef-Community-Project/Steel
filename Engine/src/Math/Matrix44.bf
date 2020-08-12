using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix44_t<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		public const let ROWS = 4;
		public const let COLUMNS = 4;
		public const let SIZE = ROWS * COLUMNS;

		public T[ROWS][COLUMNS] data2d;
		public T[SIZE] data;                          
		public Vector4_t<T>[COLUMNS] columns;

		public this()
		{
			this = default;
		}

		public this(T m00, T m01, T m02, T m03,
					T m10, T m11, T m12, T m13,
					T m20, T m21, T m22, T m23,
					T m30, T m31, T m32, T m33)
		{
			data = .(m00, m01, m02, m03,
					m10, m11, m12, m13,
					m20, m21, m22, m23,
					m30, m31, m32, m33);
		}

		public this(T[SIZE] values)
		{
			data = values;
		}

		public this(Vector4_t<T> c1, Vector4_t<T> c2, Vector4_t<T> c3, Vector4_t<T> c4)
		{
			columns = .(c1, c2, c3, c4);
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

		public T m30 { [Inline] get { return data[12]; } [Inline] set mut { data[12] = value; } }
		public T m31 { [Inline] get { return data[13]; } [Inline] set mut { data[13] = value; } }
		public T m32 { [Inline] get { return data[14]; } [Inline] set mut { data[14] = value; } }
		public T m33 { [Inline] get { return data[15]; } [Inline] set mut { data[15] = value; } }

		public T this[int i]
		{
			get { return data[i]; }
			set mut { data[i] = value; }
		}

		public T this[int row, int column]
		{
			get { return data2d[column][row]; }
			set mut { data2d[column][row] = value; }
		}

		public Vector4_t<T> Column(int i)
		{
			return columns[i];
		}

		public static Self Zero => .(0,0,0,0,
									 0,0,0,0,
									 0,0,0,0,
									 0,0,0,0);

		public static Self Identity => .(1,0,0,0,
										 0,1,0,0,
										 0,0,1,0,
										 0,0,0,1);

		public Self Inverse
		{
			[Error("Not implemented")]
			get {
				Self inverse = ?;
				
				// @TODO(fusion)
				return inverse;
			}
		}

		public T Trace
		{
			[Inline]
			get
			{
				return data2d[0][0] + data2d[1][1] + data2d[2][2] + data2d[3][3];
			}	
		}

		public T Determinant
		{
			get
			{
				return m00*(m11*(m22*m33 - m23*m32) - m12*(m23*m31 - m21*m33) + m13*(m21*m32 - m22*m31)) -
					   m01*(m12*(m23*m30 - m20*m33) - m13*(m20*m32 - m22*m30) + m10*(m22*m33 - m23*m32)) +
					   m02*(m13*(m20*m31 - m21*m30) - m10*(m21*m33 - m23*m31) + m11*(m23*m30 - m20*m33)) -
					   m03*(m10*(m21*m32 - m22*m31) - m11*(m22*m30 - m20*m32) + m12*(m20*m31 - m21*m30));
			}	
		}

		public void Normalize() mut
		{
			T det = 1 / Determinant;

			columns[0] *= det;
			columns[1] *= det;
			columns[2] *= det;
			columns[3] *= det;
		}

		public Self Normalized
		{
			[Inline]
			get
			{
				var tmp = this;
				return tmp..Normalize();
			}
		}

		public void Transpose() mut
		{
			Vector4_t<T>[COLUMNS] tmp = ?;
			tmp[0] = .(this[0, 0], this[0, 1], this[0, 2], this[0, 3]);
			tmp[1] = .(this[1, 0], this[1, 1], this[1, 2], this[1, 3]);
			tmp[2] = .(this[2, 0], this[2, 1], this[2, 2], this[2, 3]);
			tmp[2] = .(this[3, 0], this[3, 1], this[3, 2], this[3, 3]);
			columns = tmp;
		}

		public Self Transposed
		{
			[Inline]
			get
			{
				var tmp = this;
				return tmp..Transpose();
			}
		}

		public Matrix33_t<T> RotationMatrix
		{
			get { return .(data[0], data[1], data[2],
							data[4], data[5], data[6],
							data[8], data[9], data[10]); }
		}

		public Vector3_t<T> TranslationVector3D => columns[3].xyz;

		public Vector3_t<T> ScaleVector3D
		{
			get { return .(columns[0].xyz.Length,
							columns[1].xyz.Length,
							columns[2].xyz.Length); }
		}

		public static Self Perspective(T fovy, T aspect, T znear, T zfar, T handedness = 1)
		{
			let y = (T)(1 / Math.Tan(fovy * (T)0.5f));
			let x = y / aspect;
			let zdist = (znear - zfar);
			let zfar_per_zdist = zfar / zdist;
			return .(x, 0, 0, 0, 0, y, 0, 0, 0, 0,
					zfar_per_zdist * handedness, -1 * handedness, 0, 0,
					2.0f * znear * zfar_per_zdist, 0);
		}

		public static Self Ortho(T left, T right, T bottom, T top, T znear, T zfar, T handedness = 1)
		{
			return .((T)(2) / (right - left), 0, 0, 0, 0,
				(T)(2) / (top - bottom), 0, 0, 0, 0,
				-handedness * (T)(2) / (zfar - znear), 0,
				-(right + left) / (right - left),
				-(top + bottom) / (top - bottom),
				-(zfar + znear) / (zfar - znear), (T)(1));
		}

		public static Self LookAt(Vector3_t<T> at, Vector3_t<T> eye, Vector3_t<T> up, T handedness = 1)
		{
			Vector3_t<T>[4] axes = ?;
			axes[2] = (at - eye).Normalized;
			axes[0] = Vector3_t<T>.CrossProduct(up, axes[2]).Normalized;
			axes[1] = Vector3_t<T>.CrossProduct(axes[2], axes[0]);
			axes[3] = .(handedness * Vector3_t<T>.DotProduct(axes[0], eye),
                       -Vector3_t<T>.DotProduct(axes[1], eye),
                       handedness * Vector3_t<T>.DotProduct(axes[2], eye));

			// Default calculation is left-handed (i.e. handedness=-1).
			// Negate x and z axes for right-handed (i.e. handedness=+1) case.
			let neg = -handedness;
			axes[0] *= neg;
			axes[2] *= neg;

			Vector4_t<T> column0 = .(axes[0][0], axes[1][0], axes[2][0], 0);
			Vector4_t<T> column1 = .(axes[0][1], axes[1][1], axes[2][1], 0);
			Vector4_t<T> column2 = .(axes[0][2], axes[1][2], axes[2][2], 0);
			Vector4_t<T> column3 = .(axes[3], 1);
			return .(column0, column1, column2, column3);
		}


		public static Self Transform(Vector3_t<T> pos, Quaternion_t<T> rot, Vector3_t<T> scale)
		{
			Matrix33_t<T> rotation = rot.ToMatrix();
			Vector4_t<T> c0 = .(rotation[0, 0], rotation[1, 0], rotation[2, 0], 0);
			Vector4_t<T> c1 = .(rotation[0, 1], rotation[1, 1], rotation[2, 1], 0);
			Vector4_t<T> c2 = .(rotation[0, 2], rotation[1, 2], rotation[2, 2], 0);
			Vector4_t<T> c3 = .(0, 0, 0, 1);
			c0 *= scale.x;
			c1 *= scale.y;
			c2 *= scale.z;
			c3[0] = pos.x;
			c3[1] = pos.y;
			c3[2] = pos.z;
			return .(c0, c1, c2, c3);
		}

		public static Self Translation(Vector3_t<T> pos)
		{
			return .(1, 0, 0, 0,
					 0, 1, 0, 0,
					 0, 0, 1, 0,
					 pos.x, pos.y, pos.z, 1);
		}

		public static Self Scale(Vector3_t<T> scale)
		{
			return .(scale.x, 0, 0, 0,
					0, scale.y, 0, 0,
					0, 0, scale.z, 0,
					0, 0, 0, 1);
		}

		public static Self RotationX(T angle)
		{
			Self m = .Identity;

			T cosT = (T)Math.Cos(angle);
			T sinT = (T)Math.Sin(angle);
			m.columns[1].y = cosT;
			m.columns[1].z = -sinT;
			m.columns[2].y = sinT;
			m.columns[2].z = -cosT;

			return m;
		}

		public static Self RotationY(T angle)
		{
			Self m = .Identity;

			T cosT = (T)Math.Cos(angle);
			T sinT = (T)Math.Sin(angle);
			m.columns[0].x = cosT;
			m.columns[0].z = sinT;
			m.columns[2].x = -sinT;
			m.columns[2].z = cosT;

			return m;
		}

		public static Self RotationZ(T angle)
		{
			Self m = .Identity;

			T cosT = (T)Math.Cos(angle);
			T sinT = (T)Math.Sin(angle);
			m.columns[0].x = cosT;
			m.columns[0].y = -sinT;
			m.columns[1].x = sinT;
			m.columns[1].y = cosT;

			return m;
		}
	}
}
