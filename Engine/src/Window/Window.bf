using System;
using glfw_beef;

using SteelEngine.Events;
using SteelEngine.GL;
using SteelEngine.Math;

namespace SteelEngine.Window
{
	// WindowConfig is used to specify properties of a Window before initializing it.
	// Only Width and Height are necessary. The rest is optional and has sensible default parameters
	struct WindowConfig
	{
		// NOTE(Sheep): still missing a few flags
		public StringView Title;
		public int Width;
		public int Height;
		public bool Undecorated;
		public bool Resizable;
		public bool VSync;
		public bool Maximized;
		public bool Invisible;

		public this(int width, int height, StringView title = "Steel Window",
			bool undecorated = false, bool resizable = false, bool vsync = false, bool max = false, bool inv = false)
		{
			this.Title = title; this.Width = width; this.Height = height;
			this.Undecorated = undecorated; this.Resizable = resizable; this.VSync = vsync;
			this.Maximized = max; this.Invisible = inv;
		}
	}

	// Window is a window handler. It is used to draw, receive input, etc..
	class Window
	{
		public delegate void EventCallback(Event event);

		private GlfwWindow* _handle;
		private Vector2<int> _size;
		private bool _vSync;
		private EventCallback _eventCallback;

		public GlfwWindow* GetHandle { get { return _handle; } }
		public Vector2<int> GetSize { get { return _size; } }

		public this(WindowConfig cfg, EventCallback callback)
		{
			this._size.x = cfg.Width;
			this._size.y = cfg.Height;
			this._vSync = cfg.VSync;
			this._eventCallback = callback;
			
			if (!Glfw.Init())
			{
				// If GLFW can't initialize, just crash the program
				Log.Fatal("Could not initialize GLFW");
			}

			Glfw.WindowHint(GlfwWindow.Hint.ContextVersionMajor, 4);
			Glfw.WindowHint(GlfwWindow.Hint.ContextVersionMinor, 6);
			Glfw.WindowHint(GlfwWindow.Hint.OpenGlProfile, .CoreProfile);
			Glfw.WindowHint(GlfwWindow.Hint.OpenGlForwardCompat, Glfw.TRUE);

			// TODO(Sheep): few other flags to set
			Glfw.WindowHint(GlfwWindow.Hint.Decorated, !cfg.Undecorated);
			Glfw.WindowHint(GlfwWindow.Hint.Resizable, cfg.Resizable);
			Glfw.WindowHint(GlfwWindow.Hint.Maximized, cfg.Maximized);
			Glfw.WindowHint(GlfwWindow.Hint.Visible, !cfg.Invisible);


			this._handle = Glfw.CreateWindow(cfg.Width, cfg.Height, cfg.Title, null, null);

			if (this._handle == null)
			{
				// If a window can't be opened, just crash the program too
				Log.Fatal("Could not initialize a window");
			}

			Glfw.MakeContextCurrent(this._handle);
			GL.Init(=> Glfw.GetProcAddress);

			// Set all the custom GLFW callbacks
			// Close callback
			void closeC(GlfwWindow* window)
			{
				WindowCloseEvent event = scope WindowCloseEvent();
				_eventCallback(event);
			}
			Glfw.WindowCloseCallback closeCallback = new => closeC;
			Glfw.SetWindowCloseCallback(this._handle, closeCallback);

			// Resize callback
			void sizeC(GlfwWindow* window, int width, int height)
			{
				_size.x = width;
				_size.y = height;
				WindowResizeEvent event = scope WindowResizeEvent(width, height);
				_eventCallback(event);
			}	
			Glfw.WindowSizeCallback sizeCallback = new => sizeC;
			Glfw.SetWindowSizeCallback(this._handle, sizeCallback);

			// Key callback
			void keyC(GlfwWindow* window, GlfwInput.Key key, int scancode, GlfwInput.Action action, int mods)
			{
				switch (action)
				{
					case GlfwInput.Action.Press:
						KeyPressedEvent event = scope KeyPressedEvent((int)key, 0);
						_eventCallback(event);
						break;
					case GlfwInput.Action.Release:
						KeyReleasedEvent event = scope KeyReleasedEvent((int)key);
						_eventCallback(event);
						break;
					case GlfwInput.Action.Repeat:
						KeyPressedEvent event = scope KeyPressedEvent((int)key, 1);
						_eventCallback(event);
						break;
				}
			}
			Glfw.KeyCallback keyCallback = new => keyC;
			Glfw.SetKeyCallback(this._handle, keyCallback);

			// Mouse button callback
			void mouseC(GlfwWindow* window, GlfwInput.MouseButton button, GlfwInput.Action action, int mods)
			{
				switch (action)
				{
					case GlfwInput.Action.Press:
						MouseButtonPressedEvent event = scope MouseButtonPressedEvent((int)button);
						_eventCallback(event);
						break;
					case GlfwInput.Action.Release:
						MouseButtonReleasedEvent event = scope MouseButtonReleasedEvent((int)button);
						_eventCallback(event);
						break;
					case GlfwInput.Action.Repeat:
						MouseButtonPressedEvent event = scope MouseButtonPressedEvent((int)button);
						_eventCallback(event);
						break;
				}
			}
			Glfw.MouseButtonCallback mouseCallback = new => mouseC;
			Glfw.SetMouseButtonCallback(this._handle, mouseCallback);

			// Mouse scroll callback
			void mouseScrollC(GlfwWindow* window, double xOffset, double yOffset)
			{
				MouseScrolledEvent event = scope MouseScrolledEvent((float)xOffset, (float)yOffset);
				_eventCallback(event);
			}
			Glfw.ScrollCallback scrollCallback = new => mouseScrollC;
			Glfw.SetScrollCallback(this._handle, scrollCallback);

			// Mouse movement callback
			void mouseMovementC(GlfwWindow* window, double x, double y)
			{
				MouseMovedEvent event = scope MouseMovedEvent((float)x, (float)y);
				_eventCallback(event);
			}
			Glfw.CursorPosCallback mouseMovedCallback = new => mouseMovementC;
			Glfw.SetCursorPosCallback(this._handle, mouseMovedCallback);
		}

		public void Update()
		{
			switch(_vSync)
			{
			case true : Glfw.SwapInterval(1);
			case false: Glfw.SwapInterval(0);
			}

			Glfw.PollEvents();
			Glfw.SwapBuffers(_handle);
		}

		public void Destroy()
		{
			Glfw.DestroyWindow(_handle);
			Glfw.Terminate();
		}

		// SetTitle changes the title of the Window
		public void SetTitle(StringView title)
		{
			Glfw.SetWindowTitle(_handle, title);
		}
	}	
}
