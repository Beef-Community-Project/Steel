using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class RenderTextSystem : BaseSystem
	{
		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(TextComponent), typeof(TransformComponent) };
		}
	}
}
