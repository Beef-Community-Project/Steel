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
		public static uint8[] AllocateBuffer(Object data)
		{
			return new uint8[GetOutputSize(data)];
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
				Log.Trace("Detected String: {}", ((String) object).Length + 1);
				return ((String) object).Length + 1;
			}
			else if (object is StringView)
			{
				Log.Trace("Detected String: {}", ((StringView) object).Length + 1);
				return ((StringView) object).Length + 1;
			}

			var fields = object.GetType().GetFields();
			for (var field in fields)
			{
				var valueResult = field.GetValue(object);

				if (valueResult case .Err)
					return 0;

				var valueVariant = valueResult.Get();

				var prevNameSize = size;
				var name = field.GetName();
				size += name.Length + 1;
				Log.Trace("Detected field name: {}", size - prevNameSize);
				if (field.FieldType.IsPrimitive)
				{
					var prevSize = size;
					size += GetPrimitiveSize(valueVariant);
					Log.Trace("Detected primitive: {}", size - prevSize);
				}
				else if (field.FieldType.IsStruct)
				{
					var prevSize = size;
					var fieldObject = valueVariant.GetBoxed().Get();
					size += GetOutputSize(fieldObject);
					delete fieldObject;
					Log.Trace("Length increased after struct: {}", size - prevSize);
				}
				else
				{
					var prevSize = size;
					size += GetOutputSize(valueVariant.Get<Object>());
					Log.Trace("Length increased after object: {}", size - prevSize);
				}

				valueVariant.Dispose();
			}

			Log.Trace("Detected object: {}", size);

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

		public static Result<void, SerializationError> Serialize(Object object, Stream output)
		{
			return .Err(.NotImplemented);
		}

		public static Result<void, SerializationError> Serialize(Object object, uint8[] output)
		{
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
				Log.Trace("Write string: {}", (object as String).Length + 1);
				packer.Write((String) object);
				return .Ok;
			}
			else if (object is StringView)
			{
				Log.Trace("Write string: {}", ((StringView)object).Length + 1);
				packer.Write((StringView) object);
				return .Ok;
			}

			// User defined class
			var fields = object.GetType().GetFields();
			var prevSize = GetBufferSize(packer.[Friend]mBuffer);
			uint32 fieldCount = 0;
			for (var field in fields)
				fieldCount++;
			packer.WriteMapHeader(fieldCount);

			fields.Reset();
			for (var field in fields)
			{
				var valueResult = field.GetValue(object);

				if (valueResult case .Err)
					return .Err(.FieldValError);

				var valueVariant = valueResult.Get();

				var prevNameSize = GetBufferSize(packer.[Friend]mBuffer);
				var name = field.GetName();
				packer.Write(name);
				var newNameSize = GetBufferSize(packer.[Friend]mBuffer);
				Log.Trace("Write field name: {}", newNameSize - prevNameSize);
				if (field.FieldType.IsPrimitive)
				{
					var _prevSize = GetBufferSize(packer.[Friend]mBuffer);
					WritePrimitive(packer, valueVariant);
					var newSize = GetBufferSize(packer.[Friend]mBuffer);
					Log.Trace("Write primitive: {}", newSize - _prevSize);
				}
				else if (field.FieldType.IsStruct)
				{
					var _prevSize = GetBufferSize(packer.[Friend]mBuffer);
					var fieldObject = valueVariant.GetBoxed().Get();
					WriteObject(packer, fieldObject);
					delete fieldObject;
					var newSize = GetBufferSize(packer.[Friend]mBuffer);
					Log.Trace("Length increased after write struct: {}", newSize - _prevSize);
				}
				else
				{
					var _prevSize = GetBufferSize(packer.[Friend]mBuffer);
					WriteObject(packer, valueVariant.Get<Object>());
					var newSize = GetBufferSize(packer.[Friend]mBuffer);
					Log.Trace("Length increased after write object: {}", newSize - _prevSize);
				}

				valueVariant.Dispose();
			}

			var newSize = GetBufferSize(packer.[Friend]mBuffer);
			var gap = newSize - prevSize;
			Log.Trace("Write object: {}",  gap);

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
