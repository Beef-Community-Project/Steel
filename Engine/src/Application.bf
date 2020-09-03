using System;
using System.Collections;
using System.IO;
using SteelEngine.Window;
using SteelEngine.Events;
using SteelEngine.Input;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using SteelEngine.ECS.Components;
using SteelEngine.Console;
using glfw_beef;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		public static Application Instance;

		private bool _isRunning = false;

		public Window Window { get; protected set; }
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;

		private LayerStack _layerStack = new .();

		private Glfw.ErrorCallback _errorCallback = new => OnGlfwError;

		private List<BaseSystem> _systems ~ DeleteContainerAndItems!(_);

		private Dictionary<ComponentId, BaseComponent> _components ~ delete _;
		private List<BaseComponent> _componentsToDelete ~ delete _;
		private List<EntityId> _entitiesToRemoveFromStore ~ delete _;
		private GLFWInputManager _inputManager = new GLFWInputManager() ~ delete _;

		private GameConsole _gameConsole = new GameConsole() ~ delete _;

		public this()
		{
			Instance = this;

			Log.AddCallback(new (str, level) =>
			{
				ConsoleColor color;

				switch (level)
				{
				case .Trace:
					color = .Gray;
					break;
				case .Info:
					color = .White;
					break;
				case .Warning:
					color = .Yellow;
					break;
				case .Error, .Fatal:
					color = .Red;
					break;
				}

				var origin = Console.ForegroundColor;
				Console.ForegroundColor = color;
				Console.WriteLine(str);
				Console.ForegroundColor = origin;
			});

			Log.Trace("Initializing application");

			_gameConsole.Initialize(scope String[]("config.cfg"));

			_components = new Dictionary<ComponentId, BaseComponent>();
			_componentsToDelete = new List<BaseComponent>();
			_entitiesToRemoveFromStore = new List<EntityId>();

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

		/// <summary>
		/// Creates a new <see cref="SteelEngine.ECS.BaseSystem"/>. This operation is expensive, as it runs through all entities and registers viable ones to the new system.
		/// Systems should be added as close to the start of the <see cref="SteelEngine.Application"/> as possible to avoid slowdowns.
		/// </summary>
		public BaseSystem CreateSystem<T>() where T : BaseSystem
		{
			let system = new T();
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
				system.[Friend]RefreshEntityRegistration(entity.Id);
			}

			return system;
		}

		public Entity CreateEntity()
		{
			return new Entity();
		}

		public void Run()
		{
			_isRunning = true;

			var windowConfig = WindowConfig(
				1080,          // Width
				720,           // Height
				"SteelEngine", // Title
				false,         // Undecorated
				true,          // Resizable
				false,         // VSync
				false,         // Maximized
				false          // Invisible
			);

			Window = new Window(windowConfig, _eventCallback);

			OnInit();

			Glfw.SetErrorCallback(_errorCallback, true);

			Time.[Friend]Initialize();
			_inputManager.Initialize();

			for (let system in _systems)
			{
				switch (system.[Friend]Initialize())
				{
					case .Ok: continue;
					case .Err(.AlreadyInitialized): Log.Warning("Tried to initialize a system that was already initialized.");
					case .Err(.Unknown):
					default: Log.Fatal("Unknown error initializing a system");
				}
			}

			while (_isRunning)
			{
				for (var layer in _layerStack)
					layer.OnUpdate();

				Window.Update();

				Update();
				Draw();
			}

			OnCleanup();
		}

		// Gets called right after the window is created
		public virtual void OnInit() {}

		// Gets called when the window is destroyed
		public virtual void OnCleanup() {}

		// Gets called when an event occurs in the window
		public void OnEvent(Event event)
		{
			var dispatcher = scope EventDispatcher(event);
			dispatcher.Dispatch<WindowCloseEvent>(scope => OnWindowClose);

			for (var layer in _layerStack)
			{
				layer.OnEvent(event);
				if (event.IsHandled)
					return;
			}

			_inputManager.OnEvent(event);
		}

		private void OnGlfwError(Glfw.Error error)
		{
			Log.Error("(GLFW) {}", error);
		}

		private bool OnWindowClose(WindowCloseEvent event)
		{
			_isRunning = false;
			return true;
		}

		protected virtual void OnUpdate() { }

		private void Update()
		{
			let dt = Time.[Friend]Update();

			_inputManager.Update();

			DeleteQueuedComponents();
			DeleteQueuedEntities();

			for (let system in _systems)
			{
				system.[Friend]PreUpdate();
				system.[Friend]Update(dt);
				system.[Friend]PostUpdate();
			}

			for (var layer in _layerStack)
				layer.OnUpdate();

			_gameConsole.Update();

			OnUpdate();
		}

		public void PushLayer(Layer layer)
		{
			_layerStack.PushLayer(layer);
		}

		public void PushOverlay(Layer layer)
		{
			_layerStack.PushOverlay(layer);
		}

		public static T GetInstance<T>() where T : Application
		{
			return (T) Instance;
		}

		struct PosColorVertex
		{
			public this(float x, float y, float z, uint32 abgr)
			{
				this.x = x;
				this.y = y;
				this.z = z;
				this.abgr = abgr;
			}

			float x, y, z;
			uint32 abgr;
		}

		private void Draw()
		{
			for (let system in _systems)
			{
				system.[Friend]Draw();
			}

			Window.Update();
		}


		private bool AddComponent(BaseComponent component)
		{
			if (_components.ContainsKey(component.Id))
			{
				return false;
			}
			var parent = component.Parent;
			if (parent == null)
			{
				return false;
			}

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
			}
			_components[component.Id] = component;
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
				for (let system in _systems)
				{
					system.[Friend]RemoveComponent(component);
				}
				_components.Remove(component.Id);
				delete component;
			}
		}

		private void DeleteQueuedEntities()
		{
			for (let entityId in _entitiesToRemoveFromStore)
			{
				Entity entity = ?;
				if (Entity.EntityStore.TryGetValue(entityId, out entity))
				{
					delete entity;
					Entity.EntityStore.Remove(entityId);
				}
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
				if (component?.Parent != null && component.Parent.Id == entity.Id)
				{
					RemoveComponent(component);
				}
			}
			_entitiesToRemoveFromStore.Add(entity.Id);
			return true;
		}

		public static void Exit(int exitCode = 0)
		{
			Environment.Exit(exitCode);
		}

		public ~this()
		{
			Dispose();
		}

		public virtual void Dispose()
		{
			delete _layerStack;

			Window.Destroy();
			delete Window;

			// Order of deletion is important. Deleting from lowest to highest abstraction is safe.
			for (let item in _components)
				delete item.value;

			_components.Clear();

			for (let item in Entity.EntityStore)
				delete item.value;
		}
	}
}
