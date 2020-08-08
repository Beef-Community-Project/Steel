using System;

namespace SteelEngine.Math
{
	[CRepr]
	public struct Vector2_t<T> : IHashable where T :  IHashable
	{
		public T[2] data;

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

		public T this[int i]
		{
			[Inline] get { return data[i]; }
			[Inline] set mut { data[i] = value; }
		}

		public this()
		{
			data = default;
		}

		public this(T x)
		{
		 	data = T[](x, default);
		}

		public this(T x, T y)
		{
			data = T[](x, y);
		}

		public this(T[2] values)
		{
			data = values;
		}

		public static bool operator ==(Self v1, Self v2)
		{
		    return (v1.x == v2.x) &&
		        (v1.y == v2.y);
		}

		public static bool operator !=(Self value1, Self value2)
		{
		    return !(value1 == value2);
		}

		public override void ToString(String str)
		{
		    str.AppendF("{0:0.0#}, {1:0.0#}", x, y);
		}

		public int GetHashCode()
		{
			int seed = 0;
			Helpers.HashCombine(ref seed, x.GetHashCode());
			Helpers.HashCombine(ref seed, y.GetHashCode());
			return seed;
		}
	}

	public extension Vector2_t<T> where T : var, IOpAddable
	{
		public static Self Zero => .(0, 0);
		public static Self One => .(1, 1);

		public static Self Left => .(1, 0);
		public static Self Right => .(-1, 0);
		public static Self Up => .(0, 1);
		public static Self Down => .(0, -1);
	}

	public extension Vector2_t<T> where T : var, Float
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity);
	}

	public extension Vector2_t<T> where T : var, Double
	{
		public static Self PositiveInfinity => .(T.PositiveInfinity, T.PositiveInfinity);
		public static Self NegativeInfinity => .(T.NegativeInfinity, T.NegativeInfinity);
	}

	public extension Vector2_t<T> where T : IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
	{
		// These 4 methods are here because in generic var context the compiler sometimes can't figure out which operator overload to use
		// @TODO(fusion) : remove once the issue is fixed
		public static Self Add(Self v1, Self v2)
		{
			return .(v1.x + v2.x, v1.y + v2.y);
		}

		public static Self Subtract(Self v1, Self v2)
		{
			return .(v1.x - v2.x, v1.y - v2.y);
		}

		public static Self Multiply(Self v1, Self v2)
		{
			return .(v1.x * v2.x, v1.y * v2.y);
		}

		public static Self Divide(Self v1, Self v2)
		{
			return .(v1.x / v2.x, v1.y / v2.y);
		}

		public void operator+=(Self rv) mut
		{
			x += rv.x;
			y += rv.y;
		}

		public static Self operator+(Self lv, Self rv)
		{
			return .(lv.x + rv.x, lv.y + rv.y);
		}

		public void operator+=(T rv) mut
		{
			x += rv;
			y += rv;
		}

		public static Self operator+(Self lv, T rv)
		{
			return .(lv.x + rv, lv.y + rv);
		}

		public static Self operator-(Self lv)
		{
			return .(-lv.x, -lv.y);
		}

		public void operator-=(Self rv) mut
		{
			x -= rv.x;
			y -= rv.y;
		}

		public static Self operator-(Self lv, Self rv)
		{
			return .(lv.x - rv.x, lv.y - rv.y);
		}

		public void operator-=(T rv) mut
		{
			x -= rv;
			y -= rv;
		}

		public static Self operator-(Self lv, T rv)
		{
			return .(lv.x - rv, lv.y - rv);
		}

		public void operator*=(Self rv) mut
		{
			x *= rv.x;
			y *= rv.y;
		}

		public static Self operator*(Self lv, Self rv)
		{
			return .(lv.x * rv.x, lv.y * rv.y);
		}

		public void operator*=(T rv) mut
		{
			x *= rv;
			y *= rv;
		}

		public static Self operator*(Self lv, T rv)
		{
			return .(lv.x * rv, lv.y * rv);
		}

		public void operator/=(Self rv) mut
		{
			x /= rv.x;
			y /= rv.y;
		}

		public static Self operator/(Self lv, Self rv)
		{
			return .(lv.x / rv.x, lv.y / rv.y);
		}

		public void operator/=(T rv) mut
		{
			x *= rv;
			y *= rv;
		}

		public static Self operator/(Self lv, T rv)
		{
			return .(lv.x / rv, lv.y / rv);
		}

		/// <returns>
		/// Squared length of this vector
		/// </returns>
		public T LengthSquared=> x * x + y * y;

		/// <returns>
		/// Returns the distance between vectors
		/// </returns>
		public static T DistanceSquared(Self v1, Self v2)
		{
			return (v1 - v2).LengthSquared;
		}

	}

	public extension Vector2_t<T> where T : var, IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable
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

	public extension Vector2_t<T> where T : IFloating, IOpAddable, IOpSubtractable, IOpMultiplicable, IOpDividable, IOpNegatable
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
			return .(v1.x + value * (v2.x - v1.x), v1.y + value * (v2.y - v1.y));
		}

		/// <returns>
		/// Dot product of vectors
		/// </returns>
		public static T DotProduct(Self v1, Self v2)
		{
			return v1.x * v2.x + v1.y * v2.y;
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
