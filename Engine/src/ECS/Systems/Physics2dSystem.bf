using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Physics2dSystem : BaseSystem<Physics2dComponent>
	{
		public this(Application app) : base(app) {}

		public override void Initialize()
		{
			base.Initialize();
		}

		protected override void Initialize(Physics2dComponent component)
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

		private void UpdateComponent(Physics2dComponent component, float delta)
		{
		}
	}
}
