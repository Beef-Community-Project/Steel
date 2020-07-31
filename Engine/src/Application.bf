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

		public this()
		{
			OnInit();

			var windowConfig = WindowConfig(1080, 720, "SteelEngine");

			_window = new Window(windowConfig, _eventCallback);
		}

		public ~this()
		{
			Dispose();
		}

		public void Run()
		{
			_isRunning = true;

			while (_isRunning)
			{
				_window.Update();
			}
		}

		// Gets called right before the window is created
		public virtual void OnInit() {}

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
