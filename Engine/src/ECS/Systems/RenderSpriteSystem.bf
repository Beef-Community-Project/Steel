using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class RenderSpriteSystem : BaseSystem
	{
		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(SpriteComponent), typeof(TransformComponent) };
		}
	}
}
