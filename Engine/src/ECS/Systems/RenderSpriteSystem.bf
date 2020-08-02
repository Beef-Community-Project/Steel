using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class RenderSpriteSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void DrawComponent(BaseComponent component)
		{
		}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(SpriteComponent), typeof(TransformComponent) };
		}
	}
}
