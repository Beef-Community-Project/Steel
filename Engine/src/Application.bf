using System;
using SteelEngine.Window;
using SteelEngine.Events;
using SteelEngine.Input;

namespace SteelEngine
{
	public abstract class Application : IDisposable
	{
		private bool _isRunning = false;

		private Window _window ~ delete _;
		private Window.EventCallback _eventCallback = new => OnEvent ~ delete _;
		private GLFWInputManager _inputSystem = new GLFWInputManager() ~ delete _;

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

			_inputSystem.Initialize();

			while (_isRunning)
			{
				_inputSystem.Update();
				
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
			_inputSystem.OnEvent(event);

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
