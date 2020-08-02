using System.Collections;
using SteelEngine.ECS.Components;
using System;

namespace SteelEngine.ECS.Systems
{
	/// <summary>
	/// Defines the abstract classes for all <see cref="SteelEngine.ECS.Systems"/> classes.
	/// </summary>
	public abstract class BaseSystem
	{
		protected this(Application app)
		{
			App = app;
			IsEnabled = true;
			Components = new Dictionary<uint64, BaseComponent>();
			_uninitializedComponents = new Queue<BaseComponent>();
			_componentRegistrationChecks = new List<BaseComponent>();

			RegisterComponentTypes();
		}

		public Application App { get; protected set; }

		/// <summary>
		/// All tracked components.
		/// </summary>
		public Dictionary<uint64, BaseComponent> Components ~ delete _;

		/// <summary>
		/// Whether or not the System has called <see cref="Initialize()"/>.
		/// </summary>
		public bool IsEnabled { get; set; }

		/// <summary>
		/// Whether or not the System has called <see cref="Initialize()"/>.
		/// </summary>
		public bool IsInitialized { get; protected set; }

		public virtual void Draw()
		{
			if (!IsEnabled)
			{
				return;
			}
			InitializeComponents();
			for (let item in Components)
			{
				DrawComponent(item.value);
			}
		}

		public T GetComponent<T>(uint64 id) where T : BaseComponent
		{
			BaseComponent component = ?;
			uint64 matchKey = ?;
			Components.TryGet(id, out matchKey, out component);
			if (component is T)
			{
				return component;
			}
			return null;
		}

		/// <summary>
		/// Components that need registraton checks.
		/// </summary>
		protected List<BaseComponent> _componentRegistrationChecks ~ delete _;

		/// <summary>
		/// Tracks all potentially uninitialized <see cref="SteelEngine.ECS.BaseComponent"/> objects.
		/// All <see cref="SteelEngine.ECS.BaseComponent"/> objects will be initialized in the <see cref="Initialize"/>, <see cref="PreUpdate(GameTime)"/>, or <see cref="PostUpdate(GameTime)"/> methods.
		/// </summary>
		protected Queue<BaseComponent> _uninitializedComponents ~ delete _;

		/// <summary>
		/// Tracks all potentially uninitialized <see cref="SteelEngine.ECS.BaseComponent"/> objects.
		/// All <see cref="SteelEngine.ECS.BaseComponent"/> objects will be initialized in the <see cref="Initialize"/>, <see cref="PreUpdate(GameTime)"/>, or <see cref="PostUpdate(GameTime)"/> methods.
		/// </summary>
		protected Type[] _registeredTypes ~ delete _;

		/// <summary>
		/// Adds a <see cref="SteelEngine.ECS.BaseComponent"/> to relevant <see cref="Components"/>. If the <see cref="SteelEngine.ECS.BaseComponent"/> is not initialized, it will be queued for initialization.
		/// </summary>
		/// <param name="componentToAdd"><see cref="SteelEngine.ECS.BaseComponent"/> to add.</param>
		/// <returns>Whether or not the <see cref="SteelEngine.ECS.BaseComponent"/> was added to this BehaviorSystem's <see cref="Components"/>. Returns false if the <see cref="SteelEngine.ECS.BaseComponent"/> already existed.</returns>
		protected virtual bool AddComponent(BaseComponent component)
		{
			if (Components.ContainsKey(component.Id))
			{
				return false;
			}
			if (!CanBeRegistered(component))
			{
				return false;
			}

			if (!component.IsInitialized)
			{
				_uninitializedComponents.Enqueue(component);
			}
			Components[component.Id] = component;
			component.[Friend]IsQueuedForDeletion = false;
			component.[Friend]ShouldCheckParentRegistration = true;
			return true;
		}

		protected bool CanBeRegistered(BaseComponent component)
		{
			for (let type in _registeredTypes)
			{
				if (CanBeRegisteredAsType(component, type))
				{
					return true;
				}
			}
			return false;
		}

		protected bool CanBeRegisteredAsType(BaseComponent component, Type type)
		{
			let componentType = component.GetType();
			if (componentType.TypeId == type.TypeId || componentType.IsSubtypeOf(type))
			{
				return true;
			}
			return false;
		}

		protected virtual void DrawComponent(BaseComponent component) {}

		protected void GetComponentsOfEntity(Entity entity, List<BaseComponent> outList)
		{
			for (let item in Components)
			{
				let component = item.value;
				if (component.Parent != null && component.Parent.Id == entity.Id)
				{
					outList.Add(component);
				}
			}
		}

		protected virtual void Initialize()
		{
			if (!IsEnabled || IsInitialized)
			{
				return;
			}
			InitializeComponents();
			IsInitialized = true;
		}

		protected virtual void Initialize(BaseComponent component)
		{
			component.[Friend]IsInitialized = true;
		}

		protected void InitializeComponents()
		{
			while (_uninitializedComponents.Count != 0)
			{
				let component = _uninitializedComponents.Dequeue();
				if (!component.IsInitialized)
				{
					Initialize(component);
				}
			}
		}

		protected bool RefreshEntityRegistration(Entity entity)
		{
			if (entity == null)
			{
				return false;
			}

			for (let item in Components)
			{
				let component = item.value;
				if (component.Parent != null && component.Parent.Id == entity.Id)
				{
					_componentRegistrationChecks.Add(component);
				}
			}
			defer _componentRegistrationChecks.Clear();

			// Check if every required Component is present
			for (let type in _registeredTypes)
			{
				// Check all components for the registered type
				bool found = false;
				for (let component in _componentRegistrationChecks)
				{
					component.[Friend]ShouldCheckParentRegistration = false;
					if (CanBeRegisteredAsType(component, type))
					{
						found = true;
						break;
					}
				}
				if (found)
				{
					continue;
				}
				// Registered type is not present. This invalidates all components that are registered.
				for (let component in _componentRegistrationChecks)
				{
					RemoveComponent(component);
				}
				return false;
			}

			return true;
		}

		protected abstract void RegisterComponentTypes();

		protected virtual bool RemoveComponent(BaseComponent component)
		{
			return RemoveComponent(component.Id);
		}

		protected virtual bool RemoveComponent(uint64 componentId)
		{
			return Components.Remove(componentId);
		}

		protected virtual void Update(float delta)
		{
			if (!IsEnabled)
			{
				return;
			}
			InitializeComponents();

			// Before running the update, check registration status of all components.
			for (let component in _componentRegistrationChecks)
			{
				if (component.ShouldCheckParentRegistration)
				{
					RefreshEntityRegistration(component.Parent);
				}
			}
			_componentRegistrationChecks.Clear();

			for (let item in Components)
			{
				UpdateComponent(item.value, delta);
			}
		}

		protected virtual void UpdateComponent(BaseComponent component, float delta)
		{
			if (!component.IsEnabled)
			{
				return;
			}
		}
	}
}
