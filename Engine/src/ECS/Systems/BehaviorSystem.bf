using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class BehaviorSystem : BaseSystem<BehaviorComponent>
	{
		public this(Application app) : base(app) {}

		public override void Initialize()
		{
			base.Initialize();
		}

		protected override void Initialize(BehaviorComponent component)
		{
			component.[Friend]IsInitialized = true;
		}

		public void Update(float delta)
		{
			InitializeComponents();
			for (let item in Components)
			{
				let component = item.value;
				if (component.IsEnabled)
				{
					component.Update(delta);
				}
			}
		}
	}
}
