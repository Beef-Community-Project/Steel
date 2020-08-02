using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Physics3dSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(Physics3dComponent), typeof(TransformComponent) };
		}

		protected override void UpdateComponent(BaseComponent component, float delta)
		{
			base.UpdateComponent(component, delta);
		}
	}
}
