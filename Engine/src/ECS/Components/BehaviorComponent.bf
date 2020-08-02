namespace SteelEngine.ECS.Components
{
	public abstract class BehaviorComponent : BaseComponent
	{
		protected abstract void Update(float delta);
	}
}
