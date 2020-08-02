using System;
using SteelEngine.Window;
using SteelEngine.Events;
using SteelEngine.Input;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using SteelEngine.ECS.Components;
using System.Collections;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		private bool _isRunning = false;

		private Window _window ~ delete _;
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;
		private List<BaseSystem> _systems ~ delete _;
		private Dictionary<uint64, BaseComponent> _components ~ delete _;
		private List<BaseComponent> _componentsToDelete ~ delete _;

		public this()
		{
			OnInit();
		}

		public ~this()
		{
			Dispose();
		}

		public void Dispose()
		{
			OnCleanup();
		}

		/// <summary>
		/// Creates a new <see cref="SteelEngine.ECS.BaseSystem"/>. This operation is expensive, as it runs through all entities and registers viable ones to the new system.
		/// Systems should be added as close to the start of the <see cref="SteelEngine.Application"/> as possible to avoid slowdowns.
		/// </summary>
		public BaseSystem CreateSystem<T>() where T : BaseSystem
		{
			let system = new T(this);
			_systems.Add(system);

			for (let item in Entity.EntityStore)
			{
				let entity = item.value;
				for (let item in _components)
				{
					let component = item.value;
					if (component.Parent != null && component.Parent.Id == entity.Id)
					{
						system.[Friend]AddComponent(component);
					}
				}
				system.[Friend]RefreshEntityRegistration(entity);
			}

			return system;
		}

		public Entity CreateEntity()
		{
			return new Entity(this);
		}

		public void Run()
		{
			_isRunning = true;

			var windowConfig = WindowConfig(1080, 720, "SteelEngine");
			_window = new Window(windowConfig, _eventCallback);

			for (let system in _systems)
			{
				system.[Friend]Initialize();
			}

			while (_isRunning)
			{
				Update(0f); // Should eventually send a delta representing the time between frames.
				Draw();
			}
		}

		// Gets called right before the window is created
		public virtual void OnInit()
		{
			Log.AddHandle(Console.Out);

			_components = new Dictionary<uint64, BaseComponent>();
			_componentsToDelete = new List<BaseComponent>();

			_systems = new List<BaseSystem>();
			// The order of these systems will greatly affect the behavior of the engine.
			// As functionality is added, the order of these updates should become more established.
			// Maybe some kind of priority filtering could be added to make sure that systems execute in a defined order established at runtime.
			CreateSystem<Physics2dSystem>();
			CreateSystem<Physics3dSystem>();
			CreateSystem<Render3DSystem>();
			CreateSystem<RenderSpriteSystem>();
			CreateSystem<RenderTextSystem>();
			CreateSystem<SoundSystem>();
			CreateSystem<BehaviorSystem>();
		}

		// Gets called when the window is destroyed
		public virtual void OnCleanup()
		{
			_window.Destroy();

			// Order of deletion is important. Deleting from highest to lowest abstraction is safe.
			for (let system in _systems)
			{
				delete system;
			}
			for (let item in Entity.EntityStore)
			{
				delete item.value;
			}
			for (let item in _components)
			{
				delete item.value;
			}
		}

		// Gets called when an event occurs in the window
		public void OnEvent(Event event)
		{
			var dispatcher = scope EventDispatcher(event);
			dispatcher.Dispatch<WindowCloseEvent>(scope => OnWindowClose);
			dispatcher.Dispatch<KeyPressedEvent>(scope => OnKeyPressed);
			dispatcher.Dispatch<KeyReleasedEvent>(scope => OnKeyRelease);
			dispatcher.Dispatch<MouseButtonPressedEvent>(scope => OnMouseButtonPressed);
			dispatcher.Dispatch<MouseButtonReleasedEvent>(scope => OnMouseButtonReleased);

			if (event.EventType == .WindowLostFocus)
			{
				Input.ResetInput();
			}
		}

		private bool OnWindowClose(WindowCloseEvent event)
		{
			_isRunning = false;
			return true;
		}

		private bool OnKeyPressed(KeyPressedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey((.)event.KeyCode), .Down);
			return true;
		}

		private bool OnKeyRelease(KeyReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey((.)event.KeyCode), .Up);
			return true;
		}

		private bool OnMouseButtonPressed(MouseButtonPressedEvent event)
		{
			
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton((.)event.Button), .Down);
			return true;
		}

		private bool OnMouseButtonReleased(MouseButtonReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton((.)event.Button), .Up);
			return true;
		}

		private void Update(float delta)
		{
			Input.[Friend]Update();

			DeleteQueuedComponents();
			for (let system in _systems)
			{
				system.[Friend]Update(delta);
			}
		}

		private void Draw()
		{
			for (let system in _systems)
			{
				system.Draw();
			}

			_window.Update();
		}


		private bool AddComponent(BaseComponent component)
		{
			if (_components.ContainsKey(component.Id))
			{
				return false;
			}
			_components[component.Id] = component;
			for (let item in _components)
			{
				let entityComponent = item.value;
				if (entityComponent.Parent != null && entityComponent.Parent.Id == component.Parent.Id)
				{
					// Try adding all of the entity's component. If the component is already present on a system, it will not add again.
					// This makes sure that when doing an entity registration check, all available components are in the system. This allows the systems to dynamically register whole entities to run logic on.
					for (let system in _systems)
					{
						system.[Friend]AddComponent(entityComponent);
					}
				}
			}

			for (let system in _systems)
			{
				system.[Friend]AddComponent(component);
				// Now that all possible components are registered, refresh the entity registration.
				system.[Friend]RefreshEntityRegistration(component.Parent);
			}
			return true;
		}

		private void DeleteQueuedComponents()
		{
			for (let item in _components)
			{
				let component = item.value;
				if (component.IsQueuedForDeletion)
				{
					_componentsToDelete.Add(component);
				}
			}
			defer _componentsToDelete.Clear();

			for (let component in _componentsToDelete)
			{
				let parent = component.Parent;
				for (let system in _systems)
				{
					system.[Friend]RemoveComponent(component);
					system.[Friend]RefreshEntityRegistration(parent);
				}
				_components.Remove(component.Id);
				delete component;
			}
		}

		private void QueueComponentForDeletion(BaseComponent component)
		{
			component.[Friend]IsQueuedForDeletion = true;
		}

		private bool RemoveComponent(BaseComponent component)
		{
			// Queue component for deletion. Gets dequeued if added to a system.
			QueueComponentForDeletion(component);
			return true;
		}

		private bool RemoveEntity(Entity entity)
		{
			if (entity == null)
			{
				return false;
			}
			for (let item in _components)
			{
				let component = item.value;
				if (component.Parent != null && component.Parent.Id == entity.Id)
				{
					RemoveComponent(component);
				}
			}
			return true;
		}
	}
}
