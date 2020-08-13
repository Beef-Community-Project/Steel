using System;

namespace SteelEngine.Math
{
	public struct Quaternion<T> : Vector4<T> where T : IHashable
	{
		public this()
		{
			data = default;
		}

		public this(T x, T y, T z, T w)
		{
			data = .(x, y, z, w);
		}

		public this(T[4] values)
		{
			data = values;
		}

		public this(Vector3<T> v, T w)
		{
			data = .(v.x, v.y, v.z, w);
		}
	}

	public extension Quaternion<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		public static Self Identity => .(1, 0, 0, 0);

		[Error("Not implemented")]
		public static Self LookAt(Vector3<T> forward, Vector3<T> up)
		{
			// @TODO(fusion)
			//Matrix33_t<T>.LookAt(forward, up);
			return default;//FromMatrix(Matrix33_t<T>());
		}

		public void operator+=(Self rv) mut
		{
			x += rv.x;
			y += rv.y;
			z += rv.z;
			w += rv.w;
		}

		public static Self operator+(Self lv, Self rv)
		{
			return .(lv.x + rv.x, lv.y + rv.y, lv.z + rv.z, lv.z + rv.z);
		}

		public static Self operator*(Self lv, Self rv)
		{
			let w = lv.w * rv.w - Vector3<T>.DotProduct(lv.xyz, rv.xyz);
			let v = lv.w * rv.xyz + rv.w * lv.xyz + Vector3<T>.CrossProduct(lv.xyz, rv.xyz);
			return .(v, w);
		}

		 public static Vector3<T> operator*(Self lv, Vector3<T> rv)
		 {
		 	T ww = lv.w + lv.w;
		 	return ww * Vector3<T>.CrossProduct(lv.xyz, rv) + (ww * lv.w - 1) * rv +
		 	       2 * Vector3<T>.DotProduct(lv.xyz, rv) * lv.w;
		 }

		public new Self Normalized
		{
			[Inline]
			get
			{
				var tmp = this;
				return tmp..Normalize();
			}
		}

		public Matrix33<T> ToMatrix()
		{
			let x2 = x * x, y2 = y * y, z2 = z * z;
			let sx = w * x, sy = w * y, sz = w * z;
			let xz = x * z, yz = y * z, xy = x * y;
			return .(1 - 2 * (y2 + z2), 2 * (xy + sz), 2 * (xz - sy),
			        2 * (xy - sz), 1 - 2 * (x2 + z2), 2 * (sx + yz),
			        2 * (sy + xz), 2 * (yz - sx), 1 - 2 * (x2 + y2));
		}

		public Matrix44<T> ToMatrix44()
		{
			let x2 = x * x, y2 = y * y, z2 = z * z;
			let sx = w * x, sy = w * y, sz = w * z;
			let xz = x * z, yz = y * z, xy = x * y;
			return .(1 - 2 * (y2 + z2), 2 * (xy + sz), 2 * (xz - sy), (T)(0),
			        2 * (xy - sz), 1 - 2 * (x2 + z2), 2 * (sx + yz), (T)(0),
			        2 * (sy + xz), 2 * (yz - sx), 1 - 2 * (x2 + y2), (T)(0),
					(T)(0), (T)(0), (T)(0), (T)(1));
		}

		public Self Inverse => .(-x, -y, -z, w);

		public Vector3<T> EulerAngles
		{
			get
			{
				Matrix33<T> m = ToMatrix();
				T cos2 = m[0] * m[0] + m[1] * m[1];
				if (cos2 < 1e-6f)
				{
				  return .(
				      0,
				      m[2] < 0 ? (T)(0.5 * Math.PI_d) : (T)(-0.5 * Math.PI_d),
				      (T)-Math.Atan2(m[3], m[4]));
				}
				else
				{
				  return .((T)Math.Atan2(m[5], m[8]),
		                  (T)Math.Atan2(-m[2], (T)Math.Sqrt(cos2)),
		                  (T)Math.Atan2(m[1], m[0]));
				}
			}
		}

		/// <summary>
		/// The resulting angle-axis uses the full range of angles supported by quaternions
		/// </summary>
		/// <returns>
		/// Tuple containing angle and normalized axis
		/// </returns>
		public (T angle, Vector3<T> axis) AngleAxis
		{
			get
			{
				Vector3<T> axis = xyz;
				let axisLength = axis.Normalize();
				T angle = 2 * (T)Math.Atan2(axisLength, w);
				if (axisLength == 0)
				{
					// If angle = 0 and 360. All axes are correct
					return (angle, Vector3<T>(1, 0, 0));
				}
				return (angle, axis);
			}
		}

		/// <summary>
		/// Create quaternion from 3 euler angles
		/// </summary>
		public static Self FromEulerAngles(T xRotation, T yRotation, T zRotation)
		{
			Vector3<T> halfAngles = .((T)(0.5) * xRotation, (T)(0.5) * yRotation, (T)(0.5) * zRotation);
			let sinx = (T)Math.Sin(halfAngles[0]);
			let cosx = (T)Math.Cos(halfAngles[0]);
			let siny = (T)Math.Sin(halfAngles[1]);
			let cosy = (T)Math.Cos(halfAngles[1]);
			let sinz = (T)Math.Sin(halfAngles[2]);
			let cosz = (T)Math.Cos(halfAngles[2]);
			return .(sinx * cosy * cosz - cosx * siny * sinz,
					cosx * siny * cosz + sinx * cosy * sinz,
					cosx * cosy * sinz - sinx * siny * cosz,
					cosx * cosy * cosz + sinx * siny * sinz);
		}

		/// <summary>
		/// Create quaternion from 3 euler angles
		/// </summary>
		[Inline]
		public static Self FromEulerAngles(Vector3<T> angles)
		{
			return FromEulerAngles(angles.x, angles.y, angles.z);
		}

		/// <summary>
		/// Create quaternion from rotation matrix
		/// </summary>
		public static Self FromMatrix(Matrix33<T> m)
		{
			let trace = m[0, 0] + m[1, 1]+ m[2, 2];
			if (trace > 0)
			{
				let s = (T)Math.Sqrt(trace + 1) * 2;
				let oneOverS = 1 / s;
				return .((T)(0.25) * s, (m[5] - m[7]) * oneOverS, (m[6] - m[2]) * oneOverS, (m[1] - m[3]) * oneOverS);
			}
			else if (m[0] > m[4] && m[0] > m[8])
			{
				let s = (T)Math.Sqrt(m[0] - m[4] - m[8] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[5] - m[7]) * oneOverS, (T)(0.25) * s, (m[3] + m[1]) * oneOverS, (m[6] + m[2]) * oneOverS);
			}
			else if (m[4] > m[8])
			{
				let s = (T)Math.Sqrt(m[4] - m[0] - m[8] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[6] - m[2]) * oneOverS, (m[3] + m[1]) * oneOverS, (T)(0.25) * s, (m[5] + m[7]) * oneOverS);
			}
			else
			{
				let s = (T)Math.Sqrt(m[8] - m[0] - m[4] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[1] - m[3]) * oneOverS, (m[6] + m[2]) * oneOverS, (m[5] + m[7]) * oneOverS, (T)(0.25) * s);
			}
		}

		/// <summary>
		/// Create quaternion from upper-left 3x3 rotation matrix of 4x4 matrix
		/// </summary>
		public static Self FromMatrix(Matrix44<T> m)
		{
			let trace = m[0, 0] + m[1, 1] + m[2, 2];
			if (trace > 0)
			{
				let s = (T)Math.Sqrt(trace + 1) * 2;
				let oneOverS = 1 / s;
				return .((T)(0.25) * s, (m[6] - m[9]) * oneOverS, (m[8] - m[2]) * oneOverS, (m[1] - m[4]) * oneOverS);
			}
			else if (m[0] > m[5] && m[0] > m[10])
			{
				let s = (T)Math.Sqrt(m[0] - m[5] - m[10] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[6] - m[9]) * oneOverS, (T)(0.25) * s, (m[4] + m[1]) * oneOverS, (m[8] + m[2]) * oneOverS);
			}
			else if (m[5] > m[10])
			{
				let s = (T)Math.Sqrt(m[5] - m[0] - m[10] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[8] - m[2]) * oneOverS, (m[4] + m[1]) * oneOverS, (T)(0.25) * s, (m[6] + m[9]) * oneOverS);
			}
			else
			{
				let s = (T)Math.Sqrt(m[10] - m[0] - m[5] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[1] - m[4]) * oneOverS, (m[8] + m[2]) * oneOverS, (m[6] + m[9]) * oneOverS, (T)(0.25) * s);
			}
		}

		public static Self FromAngleAxis(T angle, Vector3<T> axis)
		{
			let halfAngle = (T)0.5 * angle;
			return .(axis.Normalized * (T)Math.Sin(halfAngle), (T)Math.Cos(halfAngle));
		}

		public static Vector3<T> PerpendicularVector(Vector3<T> v)
		{
			var axis = Vector3<T>.CrossProduct(.(1, 0, 0), v);
			if (axis.LengthSquared > (T)0.05)
			{
				axis = Vector3<T>.CrossProduct(.(0, 1, 0), v);
			}
			return axis;
		}

		public static Self RotateFromTo(Vector3<T> from, Vector3<T> to)
		{
			let start = from.Normalized;
			let end = to.Normalized;

			let dotProduct = Vector3<T>.DotProduct(start, end);
			// Any rotation < 0.1 degrees is treated as no rotation to avoid division by zero errors
			// cos( 0.1 degrees) = 0.99999847691
			if (dotProduct >= (T)(0.99999847691)) 
				return .Identity;
			// If the vectors point in opposite directions, return a 180 degree rotation on an arbitrary axis.
			if (dotProduct <= (T)(-0.99999847691)) 
				return .(PerpendicularVector(start), 0);

			let crossProduct = Vector3<T>.CrossProduct(start, end);
			return .(crossProduct.x, crossProduct.y, crossProduct.z, (T)(1 + dotProduct)).Normalized;
		}
	}
}
