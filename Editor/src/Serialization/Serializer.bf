using System;
using System.Collections;
using System.IO;
using System.Reflection;
using SteelEngine;
using MsgPackBf;

namespace SteelEditor.Serialization
{
	public static class Serializer
	{
		public static Result<void, SerializationError> Deserialize(String source, Object object) => Deserialize(scope StringStream(source, .Reference), object);
		public static Result<void, SerializationError> DeserializeFile(StringView path, Object object) => Deserialize(scope FileStream()..Open(path, .Read), object);

		public static Result<void, SerializationError> Deserialize(Stream source, Object object)
		{
			var buffer = new uint8[source.Length];
			for (int i = 0; i < source.Length; i++)
				buffer[i] = source.Read<uint8>();
			return Deserialize(buffer, object);
		}

		public static Result<void, SerializationError> Deserialize(Span<uint8> source, Object object)
		{
			var unpacker = scope MsgUnpacker(source);
			return DeserializeObject(unpacker, object);
		}

		private static Result<void, SerializationError> DeserializeObject(MsgUnpacker unpacker, Object object)
		{
			var mapCount = unpacker.ReadMapHeader().Get();
			if (object.GetType().FieldCount != (int32) mapCount)
				return .Err(.TypeMismatch);

			for (var field in object.GetType().GetFields())
			{
				if (field.GetType().IsPrimitive)
				{
					if (unpacker.ReadMapHeader() case .Ok)
						return .Err(.TypeMismatch);
				}	
			}

			return .Ok;
		}

		public static int GetOutputSize(Object object)
		{
			int size = 1;

			if ((object as List<Object>) != null)
			{
				for (var item in (object as List<Object>))
					size += GetOutputSize(item);
				return size;
			}
			else if ((object as Dictionary<Object, Object>) != null)
			{
				for (var item in (object as Dictionary<Object, Object>))
					size += GetOutputSize(item.key) + GetOutputSize(item.value);
				return size;
			}

			if (object is String)
			{
				return ((String) object).Length + 1;
			}
			else if (object is StringView)
			{
				return ((StringView) object).Length + 1;
			}

			var fields = object.GetType().GetFields();
			for (var field in fields)
			{
				if (field.GetCustomAttribute<NoSerializeAttribute>() case .Ok)
					continue;

				var valueResult = field.GetValue(object);

				if (valueResult case .Err)
					return 0;

				var valueVariant = valueResult.Get();

				var name = field.GetName();
				size += name.Length + 1;
				if (field.FieldType.IsPrimitive)
				{
					size += GetPrimitiveSize(valueVariant);
				}
				else if (field.FieldType.IsStruct)
				{
					var fieldObject = valueVariant.GetBoxed().Get();
					size += GetOutputSize(fieldObject);
					delete fieldObject;
				}
				else
				{
					size += GetOutputSize(valueVariant.Get<Object>());
				}

				valueVariant.Dispose();
			}

			return size;
		}

		private static int GetBufferSize(Span<uint8> buffer)
		{
			int i = 0;
			bool isEmpty = true;
			for (i = buffer.Length - 1; i >= 0; i--)
			{
				if (buffer[i] != 0)
				{
					isEmpty = false;
					break;
				}
			}

			return i + 1;
		}

		private static int GetNumberSize<T>(T num) where bool : operator T < int
		{
			if (num < 0x10000)
			{
			    if (num < 0x100)
					return 1;
			    else
					return 2;
			}
			else
			{
			    if (num < 0x100000000L)
					return 4;
			    else
					return 8;
			}
		}

		private static int GetNumberSize(uint num)
		{
			if (num < 0x10000)
			{
			    if (num < 0x100)
					return 1;
			    else
					return 2;
			}
			else
			{
			    if (num < 0x100000000L)
					return 4;
			    else
					return 8;
			}
		}

		private static int GetPrimitiveSize(Variant variant)
		{
			switch (variant.VariantType)
			{
			case typeof(int):
				return GetNumberSize(variant.Get<int>());
			case typeof(int8):
				return GetNumberSize(variant.Get<int8>());
			case typeof(int16):
				return GetNumberSize(variant.Get<int16>());
			case typeof(int32):
				return GetNumberSize(variant.Get<int32>());
			case typeof(int64):
				return GetNumberSize(variant.Get<int64>());
			case typeof(uint):
				return GetNumberSize(variant.Get<uint>());
			case typeof(uint8):
				return GetNumberSize(variant.Get<uint8>());
			case typeof(uint16):
				return GetNumberSize(variant.Get<uint16>());
			case typeof(uint32):
				return GetNumberSize(variant.Get<uint32>());
			case typeof(uint64):
				return GetNumberSize((uint) variant.Get<uint64>());
			case typeof(bool):
				return 1;
			case typeof(float):
				return GetNumberSize(variant.Get<float>());
			case typeof(double):
				return GetNumberSize(variant.Get<double>());
			default:
				return 0;
			}
		}

		public static Result<void, SerializationError> Serialize(Object object, uint8[] output)
		{
			if (GetOutputSize(object) > output.Count)
				return .Err(.BufferSizeError);
			return WriteObject(scope MsgPacker(output), object);
		}

		public static Result<void, SerializationError> Serialize(Object object, out uint8[] output)
		{
			output = new uint8[GetOutputSize(object)];
			return WriteObject(scope MsgPacker(output), object);
		}

		private static Result<void, SerializationError> WriteObject(MsgPacker packer, Object object)
		{
			if (object.GetType().IsPrimitive)
				return WritePrimitive(packer, Variant.CreateFromBoxed(object));
			else if ((object as List<Object>) != null)
				return WriteList(packer, (List<Object>) object);
			else if ((object as Dictionary<Object, Object>) != null)
				return WriteMap(packer, (Dictionary<Object, Object>) object);

			if (object is String)
			{
				packer.Write((String) object);
				return .Ok;
			}
			else if (object is StringView)
			{
				packer.Write((StringView) object);
				return .Ok;
			}

			// User defined class
			var fields = object.GetType().GetFields();
			uint32 fieldCount = 0;
			for (var field in fields)
			{
				if (field.GetCustomAttribute<NoSerializeAttribute>() case .Err)
					fieldCount++;
			}
			packer.WriteMapHeader(fieldCount);

			fields.Reset();
			for (var field in fields)
			{
				if (field.GetCustomAttribute<NoSerializeAttribute>() case .Ok)
					continue;

				var valueResult = field.GetValue(object);

				if (valueResult case .Err)
					return .Err(.FieldValError);

				var valueVariant = valueResult.Get();

				if (!valueVariant.HasValue)
					return .Err(.VariantError);

				var name = field.GetName();
				packer.Write(name);
				if (field.FieldType.IsPrimitive)
				{
					WritePrimitive(packer, valueVariant);
				}
				else if (field.FieldType.IsStruct)
				{
					var fieldObject = valueVariant.GetBoxed().Get();
					WriteObject(packer, fieldObject);
					delete fieldObject;
				}
				else
				{
					WriteObject(packer, valueVariant.Get<Object>());
				}

				valueVariant.Dispose();
			}

			return .Ok;
		}

		private static Result<void, SerializationError> WriteList(MsgPacker packer, List<Object> list)
		{
			packer.WriteArrayHeader((uint32) list.Count);
			for (var item in list)
				Try!(WriteObject(packer, item));

			return .Ok;
		}

		private static Result<void, SerializationError> WriteMap(MsgPacker packer, Dictionary<Object, Object> dict)
		{
			packer.WriteMapHeader((uint32) dict.Count);
			for (var item in dict)
			{
				Try!(WriteObject(packer, item.key));
				Try!(WriteObject(packer, item.value));
			}	

			return .Ok;
		}

		private static Result<void, SerializationError> WritePrimitive(MsgPacker packer, Variant value)
		{
			switch (value.VariantType)
			{
			case typeof(int):
				packer.Write(value.Get<int>());
				break;
			case typeof(int8):
				packer.Write(value.Get<int8>());
				break;
			case typeof(int16):
				packer.Write(value.Get<int16>());
				break;
			case typeof(int32):
				packer.Write(value.Get<int32>());
				break;
			case typeof(int64):
				packer.Write(value.Get<int64>());
				break;
			case typeof(uint):
				packer.Write(value.Get<uint>());
				break;
			case typeof(uint8):
				packer.Write(value.Get<uint8>());
				break;
			case typeof(uint16):
				packer.Write(value.Get<uint16>());
				break;
			case typeof(uint32):
				packer.Write(value.Get<uint32>());
				break;
			case typeof(uint64):
				packer.Write(value.Get<uint64>());
				break;
			case typeof(bool):
				packer.Write(value.Get<bool>());
				break;
			case typeof(float):
				packer.Write(value.Get<float>());
				break;
			case typeof(double):
				packer.Write(value.Get<double>());
				break;
			default:
				return .Err(.Unknown);
			}

			return .Ok;
		}
	}
}
