using SteelEngine.Window;
using SteelEngine.Events;

namespace SteelEngine
{
	/*
	Usage:

	class Sandbox : Application
	{
		public override void OnInit()
		{
			base.OnInit();
		}
	
		public override void OnCleanup()
		{
			base.OnCleanup();
		}	
	}

	static void Main()
	{
		var app = scope Sandbox();
		app.Run();
	}

	*/
	public abstract class Application
	{
		private bool mIsRunning = false;

		private Window mWindow ~ delete _;
		private Window.EventCallback EventCallback = new => OnEvent ~ delete _;

		public this()
		{
			OnInit();

			var windowConfig = WindowConfig(1080, 720, "SteelEngine");

			mWindow = new Window(windowConfig, EventCallback);
		}

		public void Run()
		{
			mIsRunning = true;

			while (mIsRunning)
			{
				mWindow.Update();
			}
		}

		// Gets called right before the window is created
		public virtual void OnInit() {}

		// Gets called when the window is destroyed
		public virtual void OnCleanup()
		{
			mWindow.Destroy();
		}

		// Gets called when an event occurs in the window
		public void OnEvent(Event event)
		{
			var dispatcher = scope EventDispatcher(event);
			dispatcher.Dispatch<WindowCloseEvent>(scope => OnWindowClose);
		}

		bool OnWindowClose(WindowCloseEvent event)
		{
			mIsRunning = false;
			OnCleanup();

			return true;
		}
	}
}
