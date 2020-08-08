using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Matrix44_t<T> where T : var, IHashable, IFloating, IOpNegatable
	{
		public const let ROWS = 4;
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

		public T m41 { [Inline] get { return data[12]; } [Inline] set mut { data[12] = value; } }
		public T m42 { [Inline] get { return data[13]; } [Inline] set mut { data[13] = value; } }
		public T m43 { [Inline] get { return data[14]; } [Inline] set mut { data[14] = value; } }
		public T m44 { [Inline] get { return data[15]; } [Inline] set mut { data[15] = value; } }

		public T this[int i]
		{
			get { return data[i]; }
			set mut { data[i] = value; }
		}

		public T this[int x, int y]
		{
			get { return data2d[x][y]; }
			set mut { data2d[x][y] = value; }
		}

		public Vector4_t<T> Row(int i)
		{
			return rows[i];
		}

		public Self Inverse
		{
			get {
				Self inverse = ?;
				
				// @TODO
				return inverse;
			}
		}


		public Matrix33_t<T> RotationMatrix
		{
			get { return .(data[0], data[1], data[2],
							data[4], data[5], data[6],
							data[8], data[9], data[10]); }
		}

		public Vector3_t<T> TranslationVector3D => rows[3].xyz;

		public Vector3_t<T> ScaleVector3D
		{
			get { return .(rows[0].xyz.Length,
							rows[1].xyz.Length,
							rows[2].xyz.Length); }
		}

		public this()
		{
			this = default;
		}

		public this(T m11, T m12, T m13, T m14,
					T m21, T m22, T m23, T m24,
					T m31, T m32, T m33, T m34,
					T m41, T m42, T m43, T m44)
		{
			data = .(m11, m12, m13, m14,
					m21, m22, m23, m24,
					m31, m32, m33, m34,
					m41, m42, m43, m44);
		}

		public this(T[SIZE] _data)
		{
			data = _data;
		}

		public this(T[ROWS][COLUMNS] data)
		{
			data2d = data;
		}

		public this(Vector4_t<T> r1, Vector4_t<T> r2, Vector4_t<T> r3, Vector4_t<T> r4)
		{
			rows = .(r1, r2, r3, r4);
		}

		public this(Vector4_t<T>[ROWS] _rows)
		{
			rows = _rows;
		}

		public static Self Perspective(T fovy, T aspect, T znear, T zfar, T handedness = 1)
		{
			let y = 1 / Math.Tan(fovy * (T)0.5f);
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

		public static Self LookAt(Vector3_t<T> at, Vector3_t<T> eye, Vector3_t<T> up, T handedness = -1)
		{
			Vector3_t<T>[4] axes = ?;
			axes[2] = Vector3_t<T>.Subtract(at,eye).Normalized;
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
			//LookAtHelperCalculateAxes(at, eye, up, handedness, ref axes);
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
	}
}
