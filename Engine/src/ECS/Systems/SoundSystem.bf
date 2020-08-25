using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class SoundSystem : BaseSystem
	{
		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(SoundComponent), typeof(TransformComponent) };
		}
	}
}
