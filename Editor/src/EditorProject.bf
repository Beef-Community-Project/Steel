using System;
using System.Collections;
using SteelEngine.ECS;
using SteelEditor.Serialization;
using JSON_Beef.Attributes;

namespace SteelEditor
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class EditorProject
	{
		public String Name ~ delete _;
		public List<SerializableEntity> Entities ~ DeleteContainerAndItems!(_);

		[IgnoreSerialize]
		public String Path ~ delete _;

		public this() {}

		public this(StringView name, StringView path)
		{
			Name = new .(name);
			Path = new .(path);
			Entities = new .();
		}

		public static Self UntitledProject()
		{
			return new .("Untitled", "");
		}
	}
}
