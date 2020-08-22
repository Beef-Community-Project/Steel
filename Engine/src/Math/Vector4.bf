using System;
using SteelEngine.Math;

namespace SteelEngine
{
	[CRepr]
	public struct Vector4<T> : IHashable where T : IHashable
	{
		public T[4] data;

		// Creates a new Vector with default values
		public this()
		{
			data = default;
		}
		// Creates a new Vector and sets all components to v
		public this(T v)
		{
			data = .(v, v, v, v);
		}

		// Creates a new Vector with given x, y components and sets z and w to default
		public this(T x, T y)
		{
			data = .(x, y, default, default);
		}

		// Creates a new Vector with given x, y, z components and sets w to zero
		public this(T x, T y, T z)
		{
			data = .(x, y, z, default);
		}

		// Creates a new Vector with given x, y, z components
		public this(T x, T y, T z, T w)
		{
			data = .(x, y, z, w);
		}

		// Creates a new Vector with given array (0 = x, 1 = y, 2 = z, 3 = w)
		public this(T[4] values)
		{
			data = values;
		}

		public this(Vector2<T> vec2, T z, T w)
		{
			data = .(vec2.x, vec2.y, z, w);
		}

		public this(Vector3<T> vec3, T w)
		{
			data = .(vec3.x, vec3.y, vec3.z, w);
		}

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

		public Vector3<T> xyz => .(x,y,z);

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
	}

	public extension Vector4<T> where T : operator implicit float
	{
		public static Self Zero=> .(0, 0, 0, 0);
		public static Self One=> .(1, 1, 1, 1);
	}

	public extension Vector4<T>
		where T : operator implicit float
		where float : operator implicit T
	{
		public static Self PositiveInfinity => .(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity);
		public static Self NegativeInfinity => .(float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity);
	}

	public extension Vector4<T> 
		where T : operator implicit double
		where double : operator implicit T
	{
		public static Self PositiveInfinity => .(double.PositiveInfinity, double.PositiveInfinity, double.PositiveInfinity, double.PositiveInfinity);
		public static Self NegativeInfinity => .(double.NegativeInfinity, double.NegativeInfinity, double.NegativeInfinity, double.NegativeInfinity);
	}


	public extension Vector4<T> where T : operator T + T, operator T - T, operator T * T, operator T / T, operator -T
	{
		public void operator+=(Self rv) mut
		{
			x += rv.x;
			y += rv.y;
			z += rv.z;
			w += rv.w;
		}

		public static Self operator+(Self lv, Self rv)
		{
			return .(lv.x + rv.x, lv.y + rv.y, lv.z + rv.z, lv.w + rv.w);
		}

		public void operator+=(T rv) mut
		{
			x += rv;
			y += rv;
			z += rv;
			w += rv;
		}

		public static Self operator+(Self lv, T rv)
		{
			return .(lv.x + rv, lv.y + rv, lv.z + rv, lv.z + rv);
		}

		public static Self operator-(Self lv)
		{
			return .(-lv.x, -lv.y, -lv.z, -lv.w);
		}

		public void operator-=(Self rv) mut
		{
			x -= rv.x;
			y -= rv.y;
			z -= rv.z;
			w -= rv.w;
		}

		public static Self operator-(Self lv, Self rv)
		{
			return .(lv.x - rv.x, lv.y - rv.y, lv.z - rv.z, lv.w - rv.w);
		}

		public void operator-=(T rv) mut
		{
			x -= rv;
			y -= rv;
			z -= rv;
			w -= rv;
		}

		public static Self operator-(Self lv, T rv)
		{
			return .(lv.x - rv, lv.y - rv, lv.z + rv, lv.w - rv);
		}

		public void operator*=(Self rv) mut
		{
			x *= rv.x;
			y *= rv.y;
			z *= rv.z;
			w *= rv.w;
		}

		public static Self operator*(Self lv, Self rv)
		{
		    return .(lv.x * rv.x, lv.y * rv.y, lv.z * rv.z, lv.w * rv.w);
		}

		public void operator*=(T rv) mut
		{
			x *= rv;
			y *= rv;
			z *= rv;
			w *= rv;
		}

		public static Self operator*(Self lv, T rv)
		{
			return .(lv.x * rv, lv.y * rv, lv.z * rv, lv.w * rv);
		}

		public void operator/=(Self rv) mut
		{
			x /= rv.x;
			y /= rv.y;
			z /= rv.z;
			w /= rv.w;
		}

		public static Self operator/(Self lv, Self rv)
		{
			return .(lv.x / rv.x, lv.y / rv.y, lv.z / rv.z, lv.w / rv.w);
		}

		public void operator/=(T rv) mut
		{
			x /= rv;
			y /= rv;
			z /= rv;
			w /= rv;
		}

		public static Self operator/(Self lv, T rv)
		{
			return .(lv.x / rv, lv.y / rv, lv.y / rv, lv.w / rv);
		}

		/// <returns>
		/// Squared length of this vector
		/// </returns>
		public T LengthSquared=> x * x + y * y + z * z + w * w;

		/// <returns>
		/// Squared distance between two vectors
		/// </returns>
		public static T DistanceSquared(Self v1, Self v2)
		{
			return (v1 - v2).LengthSquared;
		}

	}

	public extension Vector4<T> 
		where T : operator T * T, operator T + T, operator T - T, operator T / T, operator -T, operator implicit float, operator explicit double
		where int : operator T <=> T
		where double : operator implicit T
	{
		/// <returns>
		/// Magnitude of vector
		/// </returns>
		public T Length => (T)System.Math.Sqrt(LengthSquared);

		/// <returns>
		/// Distance between vectors
		/// </returns>
		public static T Distance(Self v1, Self v2)
		{
			return (v1 - v2).Length;
		}

		/// <summary>
		/// Makes this vector have a magnitude of 1
		/// </summary>
		public T Normalize() mut
		{
			let length = Length;
			let factor = 1 / length;
			x *= factor;
			y *= factor;
			z *= factor;
			w *= factor;
			return length;
		}

		/// <returns>
		/// This vector with magnitude of 1
		/// </returns>
		public Self Normalized
		{
			get
			{
				var tmp = this;
				return tmp..Normalize();
			}
		}

		/// <returns>
		/// Unsigned angle in radians between vectors
		/// </returns>
		public static T Angle(Self v1, Self v2)
		{
			let div = (v1.Length * v2.Length);
			// div can be 0 so we need to make sure we are not dividing by zero
			if (div == 0)
				return 0;
			let cosVal = DotProduct(v1, v2) / div;
			// cosVal > 1 the Acos will return NaN
			return (T)(cosVal > 1 ? 0 : Math.Acos(cosVal));
		}

		/// <returns>
		/// Vector with magnitude clamped to value
		/// </returns>
		public static Self ClampMagnitude(Self v, T value)
		{
			let length = v.Length;
			let factor = value / length;
			return .(v.x * factor, v.y * factor, v.z * factor, v.w * factor);
		}
	}

	public extension Vector4<T> where T : operator T + T, operator T - T, operator T * T, operator -T
	{
		/// <summary>
		///	Linearly interpolates between vectors by value
		/// </summary>
		/// <returns>
		///	Vector containing interpolated value
		/// </returns>
		public static Self Lerp(Self v1, Self v2, T value)
		{
			return .(v1.x + value * (v2.x - v1.x), v1.y + value * (v2.y - v1.y), v1.z + value * (v2.z - v1.z), v1.w + value * (v2.w - v1.w));
		}

		/// <returns>
		/// Dot product of vectors
		/// </returns>
		public static T DotProduct(Self v1, Self v2)
		{
			return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z + v1.w * v2.w;
		}
	}

	public extension Vector4<T> where T : operator T <=> T
	{
		public static Self Min(Self v1, Self v2)
		{
			return .(Math.Min(v1.x, v2.x), Math.Min(v1.y, v2.y), Math.Min(v1.z, v2.z), Math.Min(v1.w, v2.w));
		}

		public static Self Max(Self v1, Self v2)
		{
			return .(Math.Max(v1.x, v2.x), Math.Max(v1.y, v2.y), Math.Max(v1.z, v2.z), Math.Max(v1.w, v2.w));
		}
	}

}
