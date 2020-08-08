using System;

namespace SteelEngine.Math
{
	[CRepr]
	public struct Vector3_t<T> : IHashable where T : IHashable
	{
		public T[3] data;

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

		public T this[int i]
		{
			[Inline] get { return data[i]; }
			[Inline] set mut { data[i] = value; }
		}

		public Vector2_t<T> xy => .(x,y);

		public this()
		{
			data = default;
		}

		public this(T x)
		{
		 	data = .(x, default, default);
		}

		public this(T x, T y)
		{
			data = .(x, y, default);
		}

		public this(T x, T y, T z)
		{
			data = .(x, y, z);
		}

		public this(T[3] values)
		{
			data = values;
		}

		public this(Vector2_t<T> v2)
		{
			data = .(v2.x, v2.y, default);
		}

		public this(Vector4_t<T> v2)
		{
			data = .(v2.x, v2.y, v2.z);
		}

		public static bool operator ==(Self value1, Self value2)
		{
		    return (value1.x == value2.x) &&
		        (value1.y == value2.y) &&
		        (value1.z == value2.z);
		}

		public static bool operator !=(Self value1, Self value2)
		{
		    return !(value1 == value2);
		}

		public override void ToString(String str)
		{
		    str.AppendF("{0:0.0#}, {1:0.0#}, {2:0.0#}", x, y, z);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, x.GetHashCode());
			Helpers.HashCombine(ref seed, y.GetHashCode());
			Helpers.HashCombine(ref seed, z.GetHashCode());
			return seed;
		}
	}

	public extension Vector3_t<T> where T : var, IOpAddable
	{
		public static Self Zero=> .(0, 0, 0);
		public static Self One=> .(1,1,1);

		public static Self Left=> .(-1, 0, 0);
		public static Self Right=> .(1, 0, 0);
		public static Self Up=> .(0, 1, 0);
		public static Self Down=> .(0, -1, 0);
		public static Self Forward=> .(0, 0, -1);
		public static Self Back=> .(0, 0, 1);
	}

	public extension Vector3_t<T> where T : var, Float
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity);
	}

	public extension Vector3_t<T> where T : var, Double
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity, T.NegativeInfinity);
	}


	public extension Vector3_t<T> where T : IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
	{
		// These 4 methods are here because in generic var context the compiler sometimes can't figure out which operator overload to use
		// @TODO(fusion) : remove once the issue is fixed
		public static Self Add(Self v1, Self v2)
		{
			return .(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z);
		}

		public static Self Subtract(Self v1, Self v2)
		{
			return .(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z);
		}

		public static Self Multiply(Self v1, Self v2)
		{
			return .(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
		}

		public static Self Divide(Self v1, Self v2)
		{
			return .(v1.x / v2.x, v1.y / v2.y, v1.z / v2.z);
		}

		public void operator+=(Self rv) mut
		{
			x += rv.x;
			y += rv.y;
			z += rv.z;
		}

		public static Self operator+(Self lv, Self rv)
		{
			return .(lv.x + rv.x, lv.y + rv.y, lv.z + rv.z);
		}

		public void operator+=(T rv) mut
		{
			x += rv;
			y += rv;
			z += rv;
		}

		public static Self operator+(Self lv, T rv)
		{
			return .(lv.x + rv, lv.y + rv, lv.z + rv);
		}

		public static Self operator-(Self lv)
		{
			return .(-lv.x, -lv.y, -lv.z);
		}

		public void operator-=(Self rv) mut
		{
			x -= rv.x;
			y -= rv.y;
			z -= rv.z;
		}

		public static Self operator-(Self lv, Self rv)
		{
			return .(lv.x - rv.x, lv.y - rv.y, lv.z - rv.z);
		}

		public void operator-=(T rv) mut
		{
			x -= rv;
			y -= rv;
			z -= rv;
		}

		public static Self operator-(Self lv, T rv)
		{
			return .(lv.x - rv, lv.y - rv, lv.z + rv);
		}

		public void operator*=(Self rv) mut
		{
			x *= rv.x;
			y *= rv.y;
			z *= rv.z;
		}

		public static Self operator*(Self lv, Self rv)
		{
		    return .(lv.x * rv.x, lv.y * rv.y, lv.z * rv.z);
		}

		public void operator*=(T rv) mut
		{
			x *= rv;
			y *= rv;
			z *= rv;
		}

		public static Self operator*(Self lv, T rv)
		{
			return .(lv.x * rv, lv.y * rv, lv.z * rv);
		}

		public void operator/=(Self rv) mut
		{
			x /= rv.x;
			y /= rv.y;
			z /= rv.z;
		}

		public static Self operator/(Self lv, Self rv)
		{
			return .(lv.x / rv.x, lv.y / rv.y, lv.z / rv.z);
		}

		public void operator/=(T rv) mut
		{
			x /= rv;
			y /= rv;
			z /= rv;
		}

		public static Self operator/(Self lv, T rv)
		{
			return .(lv.x / rv, lv.y / rv, lv.y / rv);
		}

		/// <returns>
		/// Squared length of this vector
		/// </returns>
		public T LengthSquared=> x * x + y * y + z * z;

		/// <returns>
		/// Returns the distance between vectors
		/// </returns>
		public static T DistanceSquared(Self v1, Self v2)
		{
			return (v1 - v2).LengthSquared;
		}

	}

	public extension Vector3_t<T> where T : var, IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
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

	public extension Vector3_t<T> where T : IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
	{
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
			return .(v1.x + value * (v2.x - v1.x), v1.y + value * (v2.y - v1.y), v1.z + value * (v2.z - v1.z));
		}

		/// <returns>
		/// Dot product of vectors
		/// </returns>
		public static T DotProduct(Self v1, Self v2)
		{
			return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
		}

		/// <returns>
		/// Cross product of vectors
		/// </returns>
		public static Self CrossProduct(Self v1, Self v2)
		{
			return .(v1.y * v2.z - v2.y * v1.z,
				-(v1.x * v2.z - v2.x * v1.z),
				v1.x * v2.y - v2.x * v1.y);
		}

		/// <returns>
		/// Distance between vectors
		/// </returns>
		public static T Distance(Self v1, Self v2)
		{
			return (v1 - v2).Length;
		}
	}
}
