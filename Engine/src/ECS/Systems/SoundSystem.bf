using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class SoundSystem : BaseSystem<SoundComponent>
	{
		public this(Application app) : base(app) {}

		protected override void Initialize(SoundComponent component)
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

		private void UpdateComponent(SoundComponent component, float delta)
		{
		}
	}
}
