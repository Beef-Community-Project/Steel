using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Physics3dSystem : BaseSystem
	{
		public this() : base() {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(Physics3dComponent), typeof(TransformComponent) };
		}
	}
}
