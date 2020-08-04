using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class RenderTextSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(TextComponent), typeof(TransformComponent) };
		}
	}
}
