using System;

namespace SteelEngine.Math
{
	[CRepr, Union]
	public struct Quaternion_t<T> where T : var, IHashable, IFloating, IOpNegatable
	{
		Vector3_t<T> _v;
		public T[4] data;

		public T x
		{
			[Inline] get { return data[0]; } 
			[Inline] set mut { data[0] = value; }
		}

		public T y
		{
			[Inline] get { return data[1]; }
			[Inline] set mut { data[1] = value; }
		}

		public T z
		{
			[Inline] get { return data[2]; }
			[Inline] set mut { data[2] = value; }
		}

		public T w
		{
			[Inline] get { return data[3]; }
			[Inline] set mut { data[3] = value; }
		}

		public T this[int i]
		{
			[Inline] get { return data[i]; }
			[Inline] set mut { data[i] = value; }
		}

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

		public this(Vector3_t<T> v, T w)
		{
			data = .(v.x, v.y, v.z, w);
		}

		public static bool operator ==(Self v1, Self v2)
		{
		    return (v1.x == v2.x) &&
		        (v1.y == v2.y) &&
		        (v1.z == v2.z) &&
				(v1.w == v2.w);
		}

		public static bool operator !=(Self v1, Self v2)
		{
		    return !(v1 == v2);
		}

		public override void ToString(String str)
		{
		    str.AppendF("{0:0.0#}, {1:0.0#}, {2:0.0#}, {3:0.0#}", x, y, z, w);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, x.GetHashCode());
			Helpers.HashCombine(ref seed, y.GetHashCode());
			Helpers.HashCombine(ref seed, z.GetHashCode());
			Helpers.HashCombine(ref seed, w.GetHashCode());
			return seed;
		}

		public static Self Identity => .(1, 0, 0, 0);

		public T Normalize() mut
		{
			let length = Math.Sqrt(x*x + y*y + z*y + w*w);
			let scale = 1 / length;
			x *= scale;
			y *= scale;
			z *= scale;
			w *= scale;
			return length;
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

		public Matrix33_t<T> ToMatrix()
		{
			let x2 = x * x, y2 = y * y, z2 = z * z;
			let sx = w * x, sy = w * y, sz = w * z;
			let xz = x * z, yz = y * z, xy = x * y;
			return .(1 - 2 * (y2 + z2), 2 * (xy + sz), 2 * (xz - sy),
			        2 * (xy - sz), 1 - 2 * (x2 + z2), 2 * (sx + yz),
			        2 * (sy + xz), 2 * (yz - sx), 1 - 2 * (x2 + y2));
		}

		public Matrix44_t<T> ToMatrix44()
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

		public Vector3_t<T> EulerAngles
		{
			get
			{
				Matrix33_t<T> m = ToMatrix();
				T cos2 = m[0] * m[0] + m[1] * m[1];
				if (cos2 < 1e-6f)
				{
				  return .(
				      0,
				      m[2] < 0 ? (T)(0.5 * Math.PI_d) : (T)(-0.5 * Math.PI_d),
				      -Math.Atan2(m[3], m[4]));
				}
				else
				{
				  return .(Math.Atan2(m[5], m[8]),
	                      Math.Atan2(-m[2], Math.Sqrt(cos2)),
	                      Math.Atan2(m[1], m[0]));
				}
			}
		}

		/// <summary>
		/// The resulting angle-axis uses the full range of angles supported by quaternions
		/// </summary>
		/// <returns>
		/// Tuple containing angle and normalized axis
		/// </returns>
		public (T angle, Vector3_t<T> axis) AngleAxis
		{
			get
			{
				Vector3_t<T> axis = .(x,  y, z);
				let axisLength = axis.Normalize();
				T angle = 2 * Math.Atan2(axisLength, w);
				if (axisLength == 0)
				{
					// If angle = 0 and 360. All axes are correct
					return (angle, Vector3_t<T>(1, 0, 0));
				}
				return (angle, axis);
			}
		}

		/// <summary>
		/// Create quaternion from 3 euler angles
		/// </summary>
		public static Self FromEulerAngles(T xRotation, T yRotation, T zRotation)
		{
			Vector3_t<T> halfAngles = .((T)(0.5) * xRotation, (T)(0.5) * yRotation, (T)(0.5) * zRotation);
			let sinx = Math.Sin(halfAngles[0]);
			let cosx = Math.Cos(halfAngles[0]);
			let siny = Math.Sin(halfAngles[1]);
			let cosy = Math.Cos(halfAngles[1]);
			let sinz = Math.Sin(halfAngles[2]);
			let cosz = Math.Cos(halfAngles[2]);
			return .(cosx * cosy * cosz + sinx * siny * sinz,
					sinx * cosy * cosz - cosx * siny * sinz,
					cosx * siny * cosz + sinx * cosy * sinz,
					cosx * cosy * sinz - sinx * siny * cosz);
		}

		/// <summary>
		/// Create quaternion from 3 euler angles
		/// </summary>
		[Inline]
		public static Self FromEulerAngles(Vector3_t<T> angles)
		{
			return FromEulerAngles(angles.x, angles.y, angles.z);
		}

		/// <summary>
		/// Create quaternion from rotation matrix
		/// </summary>
		public static Self FromMatrix(Matrix33_t<T> m)
 		{
			let trace = m[0, 0] + m[1, 1]+ m[2, 2];
			if (trace > 0)
			{
				let s = Math.Sqrt(trace + 1) * 2;
				let oneOverS = 1 / s;
				return .((T)(0.25) * s, (m[5] - m[7]) * oneOverS, (m[6] - m[2]) * oneOverS, (m[1] - m[3]) * oneOverS);
			}
			else if (m[0] > m[4] && m[0] > m[8])
			{
				let s = Math.Sqrt(m[0] - m[4] - m[8] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[5] - m[7]) * oneOverS, (T)(0.25) * s, (m[3] + m[1]) * oneOverS, (m[6] + m[2]) * oneOverS);
			}
			else if (m[4] > m[8])
			{
				let s = Math.Sqrt(m[4] - m[0] - m[8] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[6] - m[2]) * oneOverS, (m[3] + m[1]) * oneOverS, (T)(0.25) * s, (m[5] + m[7]) * oneOverS);
			}
			else
			{
				let s = Math.Sqrt(m[8] - m[0] - m[4] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[1] - m[3]) * oneOverS, (m[6] + m[2]) * oneOverS, (m[5] + m[7]) * oneOverS, (T)(0.25) * s);
			}
		}

		/// <summary>
		/// Create quaternion from upper-left 3x3 rotation matrix of 4x4 matrix
		/// </summary>
		public static Self FromMatrix(Matrix44_t<T> m)
		{
			let trace = m[0, 0] + m[1, 1] + m[2, 2];
			if (trace > 0)
			{
				let s = Math.Sqrt(trace + 1) * 2;
				let oneOverS = 1 / s;
				return .((T)(0.25) * s, (m[6] - m[9]) * oneOverS, (m[8] - m[2]) * oneOverS, (m[1] - m[4]) * oneOverS);
			}
			else if (m[0] > m[5] && m[0] > m[10])
			{
				let s = Math.Sqrt(m[0] - m[5] - m[10] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[6] - m[9]) * oneOverS, (T)(0.25) * s, (m[4] + m[1]) * oneOverS, (m[8] + m[2]) * oneOverS);
			}
			else if (m[5] > m[10])
			{
				let s = Math.Sqrt(m[5] - m[0] - m[10] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[8] - m[2]) * oneOverS, (m[4] + m[1]) * oneOverS, (T)(0.25) * s, (m[6] + m[9]) * oneOverS);
			}
			else
			{
				let s = Math.Sqrt(m[10] - m[0] - m[5] + 1) * 2;
				let oneOverS = 1 / s;
				return .((m[1] - m[4]) * oneOverS, (m[8] + m[2]) * oneOverS, (m[6] + m[9]) * oneOverS, (T)(0.25) * s);
			}
		}

		public static Self FromAngleAxis(T angle, Vector3_t<T> axis)
		{
			let halfAngle = 0.5 * angle;
			return .(axis.Normalized * Math.Sin(halfAngle), Math.Cos(halfAngle));
		}

		public static Vector3_t<T> PerpendicularVector(Vector3_t<T> v)
		{
			var axis = Vector3_t<T>.CrossProduct(.(1, 0, 0), v);
			if(axis.LengthSquared > 0.05)
			{
				axis = Vector3_t<T>.CrossProduct(.(0, 1, 0), v);
			}
			return axis;
		}

		public static Self RotateFromTo(Vector3_t<T> from, Vector3_t<T> to)
		{
			let start = from.Normalized;
			let end = to.Normalized;

			let dotProduct = Vector3_t<T>.DotProduct(start, end);
			// Any rotation < 0.1 degrees is treated as no rotation
			// in order to avoid division by zero errors.
			// So we early-out in cases where it's less than 0.1 degrees.
			// cos( 0.1 degrees) = 0.99999847691
			if (dotProduct >= (T)(0.99999847691)) 
				return .Identity;
			// If the vectors point in opposite directions, return a 180 degree
			// rotation, on an arbitrary axis.
			if (dotProduct <= (T)(-0.99999847691)) 
				return .(PerpendicularVector(start), 0);
			// Degenerate cases have been handled, so if we're here, we have to
			// actually compute the angle we want:

			let crossProduct = Vector3_t<T>.CrossProduct(start, end);

			return .(crossProduct, crossProduct, crossProduct, (T)(1.0) + dotProduct).Normalized;
		}

		/// <returns>
		/// Dot product of quaternions
		/// </returns>
		public static Self DotProduct(Self q1, Self q2)
		{
			return q1.x * q2.x + q1.y * q2.y + q1.z * q2.z + q1.w * q2.w;
		}

		public static Self LookAt(Vector3_t<T> forward, Vector3_t<T> up)
		{
			// @TODO(fusion)
			//Matrix33_t<T>.LookAt(forward, up);
			return FromMatrix(Matrix33_t<T>());
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
			return .(Vector3_t<T>.Add((lv.w * lv._v), Vector3_t<T>.Add(rv.w * rv._v, Vector3_t<T>.CrossProduct(lv._v, rv._v)), lv.w * rv.w - Vector3_t<T>.DotProduct(lv._v, rv._v)));
		}

		public static Self operator*(Self lv, T rv)
		{
			(var angle, var axis) = lv.AngleAxis;
			angle *= rv;
			return .(axis.Normalized * Math.Sin(0.5 * angle), Math.Cos(0.5 * angle));
		}

		//[Commutable]
		public static Self operator*(Self lv, Vector3_t<T> rv)
		{
			T ww = lv.w + lv.w;
			return .(ww * Vector3_t<T>.CrossProduct(lv._v, rv) + (ww * lv.w - 1) * rv +
			       2 * Vector3_t<T>.DotProduct(lv._v, rv) * lv._v);
		}

		
	}
}
