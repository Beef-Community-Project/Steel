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
			EntityToComponents = new Dictionary<EntityId, List<BaseComponent>>();
			_uninitializedComponents = new Queue<BaseComponent>();
			_entityRegistrationChecks = new List<EntityId>();

			RegisterComponentTypes();
		}

		public Application App { get; protected set; }

		/// <summary>
		/// All tracked components.
		/// </summary>
		public Dictionary<EntityId, List<BaseComponent>> EntityToComponents ~ delete _;

		/// <summary>
		/// Whether or not the System has called <see cref="Initialize()"/>.
		/// </summary>
		public bool IsEnabled { get; set; }

		/// <summary>
		/// Whether or not the System has called <see cref="Initialize()"/>.
		/// </summary>
		public bool IsInitialized { get; protected set; }

		/// <summary>
		/// Entities that need registration checks.
		/// </summary>
		protected List<EntityId> _entityRegistrationChecks ~ delete _;

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
			let parent = component.Parent;
			List<BaseComponent> entityComponents = ?;
			if (parent == null)
			{
				return false;
			}
			bool isNewEntity = false;
			if (!EntityToComponents.TryGetValue(parent.Id, out entityComponents))
			{
				isNewEntity = true;
				entityComponents = new List<BaseComponent>();
			}
			for (let entityComponent in entityComponents)
			{
				if (component.Id == entityComponent.Id)
				{
					return false;
				}
			}
			if (!CanBeRegistered(component))
			{
				if (isNewEntity)
				{
					delete entityComponents;
				}
				return false;
			}

			if (!component.IsInitialized)
			{
				_uninitializedComponents.Enqueue(component);
			}
			if (isNewEntity)
			{
				EntityToComponents[parent.Id] = entityComponents;
			}
			entityComponents.Add(component);
			component.[Friend]IsQueuedForDeletion = false;
			_entityRegistrationChecks.Add(parent.Id);
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

		protected void ClearEmptyEntities()
		{
			let entitiesToRemove = new List<EntityId>();
			defer delete entitiesToRemove;

			for (let item in EntityToComponents)
			{
				if (item.value == null || item.value.Count == 0)
				{
					entitiesToRemove.Add(item.key);
				}
			}
			for (let entity in entitiesToRemove)
			{
				List<BaseComponent> components = ?;
				if (EntityToComponents.TryGetValue(entity, out components))
				{
					delete components;
					EntityToComponents.Remove(entity);
				}
			}
		}

		protected virtual void Draw()
		{
			if (!IsEnabled)
			{
				return;
			}
			InitializeComponents();

			for (let item in EntityToComponents)
			{
				Draw(item.key, item.value);
			}
		}

		protected virtual void Draw(EntityId entityId, List<BaseComponent> components)
		{

		}

		protected List<BaseComponent> GetComponentsOfEntity(Entity entity)
		{
			List<BaseComponent> entityComponents = ?;
			EntityToComponents.TryGetValue(entity.Id, out entityComponents);
			return entityComponents;
		}

		protected virtual Result<void, InitializationError> Initialize()
		{
			if (!IsEnabled || IsInitialized)
			{
				return .Err(.AlreadyInitialized);
			}
			if (InitializeComponents() == .Err)
			{
				return .Err(.Unknown);
			}
			IsInitialized = true;
			return .Ok;
		}

		protected virtual Result<void> Initialize(BaseComponent component)
		{
			component.[Friend]IsInitialized = true;
			return .Ok;
		}

		protected Result<void> InitializeComponents()
		{
			while (_uninitializedComponents.Count != 0)
			{
				let component = _uninitializedComponents.Dequeue();
				if (!component.IsInitialized)
				{
					if (Initialize(component) == .Err)
					{
						return .Err;
					}
				}
			}
			return .Ok;
		}

		protected virtual void PostUpdate()
		{
			ClearEmptyEntities();
		}

		protected virtual void PreUpdate()
		{
			while (_entityRegistrationChecks.Count > 0)
			{
				let entity =  _entityRegistrationChecks.PopBack();
				RefreshEntityRegistration(entity);
			}

			ClearEmptyEntities();
		}

		protected bool RefreshEntityRegistration(EntityId entityId)
		{
			List<BaseComponent> components = ?;
			if (!EntityToComponents.TryGetValue(entityId, out components))
			{
				return false;
			}

			let componentsToRemove = new List<BaseComponent>();
			defer delete componentsToRemove;
			var valid = true;
			// Check if every required Component is present
			for (let type in _registeredTypes)
			{
				// Check all components for the registered type
				bool found = false;
				for (let component in components)
				{
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
				// Registered type is not present. This invalidates all components that are registered to this entity.
				for (let component in components)
				{
					componentsToRemove.Add(component);
				}
				valid = false;
			}
			for (let component in componentsToRemove)
			{
				RemoveComponent(component);
			}

			return valid;
		}

		protected abstract void RegisterComponentTypes();

		protected virtual bool RemoveComponent(BaseComponent component)
		{
			let parent = component.Parent;
			List<BaseComponent> components = ?;
			if (parent == null || !EntityToComponents.TryGetValue(parent.Id, out components))
			{
				return false;
			}
			if (components.Remove(component))
			{
				_entityRegistrationChecks.Add(parent.Id);
				return true;
			}
			return false;
		}

		protected virtual void Update(float delta)
		{
			if (!IsEnabled)
			{
				return;
			}
			InitializeComponents();

			for (let item in EntityToComponents)
			{
				Update(item.key, item.value, delta);
			}
		}

		protected virtual void Update(EntityId entityId, List<BaseComponent> components, float delta)
		{

		}

		public ~this()
		{
			for (let item in EntityToComponents)
			{
				delete item.value;
			}
		}
	}

	public enum InitializationError
	{
		AlreadyInitialized,
		Unknown,
	}
}
