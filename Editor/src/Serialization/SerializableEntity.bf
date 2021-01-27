using System;
using SteelEngine.ECS;

namespace SteelEditor.Serialization
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class SerializableEntity
	{
		public String Name ~ delete _;
		public bool IsEnabled;

		public this(StringView name, Entity entity)
		{
			Name = new .(name);
			IsEnabled = entity.IsEnabled;
		}

		public void MakeEntity()
		{
			var entity = new Entity();
			entity.IsEnabled = IsEnabled;

			Editor.SetEntityName(entity.Id, Name);
		}
	}
}
