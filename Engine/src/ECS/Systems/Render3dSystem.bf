using SteelEngine.ECS.Components;
using System.Collections;
using System;

namespace SteelEngine.ECS.Systems
{
	public class Render3DSystem : BaseSystem<Drawable3dComponent>
	{
		public this(Application app) : base(app) {}

		protected override void Initialize(Drawable3dComponent component)
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

		private void DrawComponent(Drawable3dComponent component)
		{
		}
	}
}
