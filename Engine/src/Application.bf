using System;
using SteelEngine.Window;
using SteelEngine.Events;
using glfw_beef;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		public static Application Instance = null;

		private bool _isRunning = false;

		public Window Window { get; protected set; }
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;

		private LayerStack _layerStack = new .() ~ delete _;

		private Glfw.ErrorCallback _errorCallback = new => OnGlfwError;

		public this()
		{
			Instance = this;
			Log.AddHandle(Console.Out);
		}

		public ~this()
		{
			Dispose();
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

			while (_isRunning)
			{
				for (var layer in _layerStack)
					layer.OnUpdate();

				Window.Update();
			}
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
					break;
			}
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

		public void Dispose()
		{
			OnCleanup();

			Window.Destroy();
			delete Window;
		}

		public void PushLayer(Layer layer)
		{
			_layerStack.PushLayer(layer);
		}

		public void PushOverlay(Layer layer)
		{
			_layerStack.PushOverlay(layer);
		}
	}
}
