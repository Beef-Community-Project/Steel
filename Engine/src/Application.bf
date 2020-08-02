using System;
using SteelEngine.Window;
using SteelEngine.Events;
using SteelEngine.Input;
using SteelEngine.ECS;
using SteelEngine.ECS.Systems;
using SteelEngine.ECS.Components;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		private bool _isRunning = false;

		private Window _window ~ delete _;
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;
		private BehaviorSystem _behaviorSystem;
		private Physics2dSystem _physics2dSystem;
		private Physics3dSystem _physics3dSystem;
		private Render3DSystem _render3dSystem;
		private RenderSpriteSystem _renderSpriteSystem;
		private RenderTextSystem _renderTextSystem;
		private SoundSystem _soundSystem;

		public this()
		{
			OnInit();
		}

		public ~this()
		{
			Dispose();
		}

		public void Run()
		{
			_isRunning = true;

			var windowConfig = WindowConfig(1080, 720, "SteelEngine");
			_window = new Window(windowConfig, _eventCallback);

			_behaviorSystem.Initialize();
			_physics2dSystem.Initialize();
			_physics3dSystem.Initialize();
			_render3dSystem.Initialize();
			_renderSpriteSystem.Initialize();
			_renderTextSystem.Initialize();
			_soundSystem.Initialize();

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

			_behaviorSystem = new BehaviorSystem(this);
			_physics2dSystem = new Physics2dSystem(this);
			_physics3dSystem = new Physics3dSystem(this);
			_render3dSystem = new Render3DSystem(this);
			_renderSpriteSystem = new RenderSpriteSystem(this);
			_renderTextSystem = new RenderTextSystem(this);
			_soundSystem = new SoundSystem(this);
		}

		// Gets called when the window is destroyed
		public virtual void OnCleanup()
		{
			_window.Destroy();

			for (let item in Entity.EntityStore)
			{
				delete item.value;
			}
			Entity.EntityStore.Clear();

			delete _behaviorSystem;
			delete _physics2dSystem;
			delete _physics3dSystem;
			delete _render3dSystem;
			delete _renderSpriteSystem;
			delete _renderTextSystem;
			delete _soundSystem;
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

			// The order of these update calls will greatly affect the behavior of the engine.
			// As functionality is added, the order of these updates should become more established.
			_physics2dSystem.Update(delta);
			_physics3dSystem.Update(delta);
			_soundSystem.Update(delta);
			_behaviorSystem.Update(delta);
		}

		private void Draw()
		{
			_render3dSystem.Draw();
			_renderSpriteSystem.Draw();
			_renderTextSystem.Draw();

			_window.Update();
		}

		public void Dispose()
		{
			OnCleanup();
		}

		private void DeleteComponentsOfEntity(Entity entity)
		{
			if (entity == null)
			{
				return;
			}

			QueueComponentsForDeletion(_behaviorSystem, entity);
			QueueComponentsForDeletion(_physics2dSystem, entity);
			QueueComponentsForDeletion(_physics3dSystem, entity);
			QueueComponentsForDeletion(_render3dSystem, entity);
			QueueComponentsForDeletion(_renderSpriteSystem, entity);
			QueueComponentsForDeletion(_renderTextSystem, entity);
		}

		private void QueueComponentsForDeletion<T>(BaseSystem<T> system, Entity entity) where T : BaseComponent
		{
			for (let item in system.Components)
			{
				let component = item.value;
				if (component.Parent != null && entity.Id == component.Parent.Id)
				{
					component.[Friend]IsQueuedForDeletion = true;
				}
			}
		}
	}
}
