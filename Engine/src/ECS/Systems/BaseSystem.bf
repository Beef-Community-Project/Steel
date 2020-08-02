using System.Collections;
using SteelEngine.ECS.Components;

namespace SteelEngine.ECS.Systems
{
	/// <summary>
	/// Defines the abstract classes for all <see cref="SteelEngine.ECS.Systems"/> classes.
	/// </summary>
	public abstract class BaseSystem<T> where T : BaseComponent, delete
	{
		protected this(Application app)
		{
			App = app;
			Components = new Dictionary<uint64, T>();
			_uninitializedComponents = new Queue<T>();
		}

	    /// <summary>
	    /// All tracked components.
	    /// </summary>
	    public Dictionary<uint64, T> Components ~ delete _;

	    /// <summary>
	    /// Reference to current <see cref="SteelEngine.Application"/> instance.
	    /// </summary>
	    public Application App { get; protected set; }

	    /// <summary>
	    /// Whether or not the System has called <see cref="Initialize()"/>.
	    /// </summary>
	    public bool IsInitialized { get; protected set; }

		public T GetComponent(uint64 id)
		{
			T component = ?;
			uint64 matchKey = ?;
			Components.TryGet(id, out matchKey, out component);
			return component;
		}

	    public virtual void Initialize()
		{
			if (IsInitialized)
			{
				return;
			}
			InitializeComponents();
			IsInitialized = true;
		}

		public void InitializeComponents()
		{
			while (_uninitializedComponents.Count != 0)
			{
				Initialize(_uninitializedComponents.Dequeue());
			}
		}

		protected abstract void Initialize(T component);

		/// <summary>
		/// Tracks all potentially uninitialized <see cref="SteelEngine.ECS.BaseComponent"/> objects.
		/// All <see cref="SteelEngine.ECS.BaseComponent"/> objects will be initialized in the <see cref="Initialize"/>, <see cref="PreUpdate(GameTime)"/>, or <see cref="PostUpdate(GameTime)"/> methods.
		/// </summary>
		protected Queue<T> _uninitializedComponents ~ delete _;

		/// <summary>
		/// Adds a <see cref="SteelEngine.ECS.BaseComponent"/> to relevant <see cref="Components"/>. If the <see cref="SteelEngine.ECS.BaseComponent"/> is not initialized, it will be queued for initialization.
		/// </summary>
		/// <param name="componentToAdd"><see cref="SteelEngine.ECS.BaseComponent"/> to add.</param>
		/// <returns>Whether or not the <see cref="SteelEngine.ECS.BaseComponent"/> was added to this BehaviorSystem's <see cref="Components"/>. Returns false if the <see cref="SteelEngine.ECS.BaseComponent"/> already existed.</returns>
		protected virtual bool AddComponent(T component)
		{
			if (!component.IsInitialized)
			{
			    _uninitializedComponents.Enqueue(component);
			}
			if (Components.ContainsKey(component.Id))
			{
			    return false;
			}
			Components[component.Id] = component;
			return true;
		}

		protected virtual bool RemoveComponent(T component)
		{
			return RemoveComponent(component.Id);
		}

		protected virtual bool RemoveComponent(uint64 componentId)
		{
			return Components.Remove(componentId);
		}

		// This current method for deletion requires that a component only be registered to one system at a time.
		// This means that for custom systems, only BehaviorComponents should ever be deleted.
		// This is reasonable to assume, as the base engine components for rendering, sound, and physics should not participate in custom systems.
		// By leaving this virtual, the object lifetime can be managed differently in custom systems.
		protected virtual void DeleteComponents(bool onlyDeletionQueuedComponents = true)
		{
			let componentsToDelete = new List<T>();
			defer delete componentsToDelete;
			for (let item in Components)
			{
				let component = item.value;
				if (!onlyDeletionQueuedComponents || component.IsQueuedForDeletion)
				{
					componentsToDelete.Add(component);
				}
			}

			for (let component in componentsToDelete)
			{
				delete component;
				RemoveComponent(component.Id);
			}
		}

		public ~this()
		{
			DeleteComponents(false);
		}
	}
}
