using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class BehaviorSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(BehaviorComponent) };
		}

		protected override void UpdateComponent(BaseComponent component, float delta)
		{
			if (!component.IsEnabled)
			{
				return;
			}
			(component as BehaviorComponent).[Friend]Update(delta);
		}
	}
}
