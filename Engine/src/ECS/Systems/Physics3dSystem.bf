using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Physics3dSystem : BaseSystem<Physics3dComponent>
	{
		public this(Application app) : base(app) {}

		public override void Initialize()
		{
			base.Initialize();
		}

		protected override void Initialize(Physics3dComponent component)
		{
			component.[Friend]IsInitialized = true;
		}

		public void Update(float delta)
		{
			InitializeComponents();
			for (let item in Components)
			{
				UpdateComponent(item.value, delta);
			}
		}

		private void UpdateComponent(Physics3dComponent component, float delta)
		{
		}
	}
}
