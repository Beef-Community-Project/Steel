using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class SoundSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(SoundComponent), typeof(TransformComponent) };
		} 

		protected override void UpdateComponent(BaseComponent component, float delta)
		{
			base.UpdateComponent(component, delta);
		}
	}
}
