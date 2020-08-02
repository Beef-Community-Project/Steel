using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class RenderSpriteSystem : BaseSystem<SpriteComponent>
	{
		public this(Application app) : base(app) {}

		protected override void Initialize(SpriteComponent component)
		{
			component.[Friend]IsInitialized = true;
		}

		public void Draw()
		{
			InitializeComponents();
			for (let item in Components)
			{
				DrawComponent(item.value);
			}
		}

		private void DrawComponent(SpriteComponent component)
		{
		}
	}
}
