using System;

namespace SteelEditor.Serialization
{
	[AttributeUsage(.Class | .Struct, ReflectUser=.NonStaticFields | .StaticFields | .DefaultConstructor | .DynamicBoxing)]
	public struct SerializableAttribute : Attribute
	{

	}

	[AttributeUsage(.Property | .Field | .StaticField)]
	public struct NoSerializeAttribute : Attribute
	{

	}
}
