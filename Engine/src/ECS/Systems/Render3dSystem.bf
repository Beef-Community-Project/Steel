using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Render3DSystem : BaseSystem
	{
		public this(Application app) : base(app) {}

		protected override void RegisterComponentTypes()
		{
			_registeredTypes = new Type[]{ typeof(Drawable3dComponent), typeof(TransformComponent) };
		}
	}
}
