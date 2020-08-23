using System;

namespace SteelEngine.ECS.Components
{
	[Reflect]
	public abstract class BehaviorComponent : BaseComponent
	{
		protected abstract void Update(float delta);
	}
}
