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

			while (_isRunning)
			{
				Input.[Friend]Update();
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
			dispatcher.Dispatch<KeyPressedEvent>(scope => OnKeyPressed);
			dispatcher.Dispatch<KeyReleasedEvent>(scope => OnKeyRelease);
			dispatcher.Dispatch<MouseButtonPressedEvent>(scope => OnMouseButtonPressed);
			dispatcher.Dispatch<MouseButtonReleasedEvent>(scope => OnMouseButtonReleased);

			if(event.EventType == .WindowLostFocus)
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
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey(event.KeyCode), .Down);
			return true;
		}

		private bool OnKeyRelease(KeyReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey(event.KeyCode), .Up);
			return true;
		}

		private bool OnMouseButtonPressed(MouseButtonPressedEvent event)
		{
			
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton(event.Button), .Down);
			return true;
		}

		private bool OnMouseButtonReleased(MouseButtonReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton(event.Button), .Up);
			return true;
		}

		public void Dispose()
		{
			OnCleanup();
		}
	}
}
