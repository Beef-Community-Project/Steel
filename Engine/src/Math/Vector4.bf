using System;

namespace SteelEngine.Math
{
	[CRepr]
	public struct Vector4_t<T> : IHashable where T : IHashable
	{
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

		public Vector3_t<T> xyz => .(x,y,z);

		public this()
		{
			data = default;
		}

		public this(Vector3_t<T> vec3, T w)
		{
			data = .(vec3.x, vec3.y, vec3.z, w);
		}

		public this(T x, T y, T z, T w)
		{
			data = .(x, y, z, w);
		}

		public this(T[4] values)
		{
			data = values;
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
	}

	public extension Vector4_t<T> where T : var, IOpAddable
	{
		public static Self Zero=> .(0, 0, 0, 0);
		public static Self One=> .(1, 1, 1, 1);
	}

	public extension Vector4_t<T> where T : var, Float
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity);
	}

	public extension Vector4_t<T> where T : var, Double
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity);
	}


	public extension Vector4_t<T> where T : IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
	{
		// These 4 methods are here because in generic var context the compiler sometimes can't figure out which operator overload to use
		// @TODO(fusion) : remove once the issue is fixed
		public static Self Add(Self v1, Self v2)
		{
			return .(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w);
		}

		public static Self Subtract(Self v1, Self v2)
		{
			return .(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.w - v2.w);
		}

		public static Self Multiply(Self v1, Self v2)
		{
			return .(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z, v1.w * v2.w);
		}

		public static Self Divide(Self v1, Self v2)
		{
			return .(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z, v1.w / v2.w);
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
		/// Returns the distance between vectors
		/// </returns>
		public static T DistanceSquared(Self v1, Self v2)
		{
			return (v1 - v2).LengthSquared;
		}

	}

	public extension Vector4_t<T> where T : var, IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable
	{
		/// <returns>
		/// Magnitude of vector
		/// </returns>
		public T Length=> System.Math.Sqrt(LengthSquared);

		/// <returns>
		/// Unsigned angle in radians between vectors
		/// </returns>
		public static T Angle(Self v1, Self v2)
		{
			return Math.Acos(Self.DotProduct(v1, v2) / (v1.Length * v2.Length));
		}
	}

	public extension Vector4_t<T> where T : IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
	{
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
		public T Normalize()	mut
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

}
