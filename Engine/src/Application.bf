using System;
using SteelEngine.Window;
using SteelEngine.Events;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		private bool _isRunning = false;

		private Window _window ~ delete _;
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;

		private LayerStack _layerStack;

		public this()
		{
			_layerStack = new LayerStack();

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

			while (_isRunning)
			{
				for (var layer in _layerStack)
					layer.OnUpdate();

				_window.Update();
			}
		}

		// Gets called right before the window is created
		public virtual void OnInit()
		{
			Log.AddHandle(Console.Out);
		}

		// Gets called when the window is destroyed
		public virtual void OnCleanup()
		{
			_window.Destroy();
		}

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

		private bool OnWindowClose(WindowCloseEvent event)
		{
			_isRunning = false;
			return true;
		}

		public void Dispose()
		{
			OnCleanup();
		}
	}
}
