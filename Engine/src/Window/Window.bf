using System;
using glfw_beef;

using SteelEngine.Events;
using SteelEngine.GL;

namespace SteelEngine.Window
{
	// NOTE(Sheep): temporary vector struct
	struct Vector2<T>
	{
		public T X;
		public T Y;
	}

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

		private GlfwWindow* mHandle;
		private Vector2<int> mSize;
		private bool mVSync;
		private bool mRunning;
		private EventCallback eventCallback;

		public GlfwWindow* GetHandle { get { return mHandle; } }
		public Vector2<int> GetSize { get { return mSize; } }
		public bool IsRunning { get { return mRunning; } set { mRunning = value; } }

		public this(WindowConfig cfg, EventCallback callback)
		{
			this.mSize.X = cfg.Width;
			this.mSize.Y = cfg.Height;
			this.mVSync = cfg.VSync;
			this.eventCallback = callback;
			
			if (!Glfw.Init())
			{
				// If GLFW can't initialize, just crash the program
				Runtime.FatalError("ERROR: Could not initialize GLFW");
			}

			Glfw.WindowHint(GlfwWindow.Hint.ContextVersionMajor, 3);
			Glfw.WindowHint(GlfwWindow.Hint.ContextVersionMinor, 3);
			Glfw.WindowHint(GlfwWindow.Hint.OpenGlProfile, .CoreProfile);
			Glfw.WindowHint(GlfwWindow.Hint.OpenGlForwardCompat, Glfw.TRUE);

			// TODO(Sheep): few other flags to set
			Glfw.WindowHint(GlfwWindow.Hint.Decorated, !cfg.Undecorated);
			Glfw.WindowHint(GlfwWindow.Hint.Resizable, cfg.Resizable);
			Glfw.WindowHint(GlfwWindow.Hint.Maximized, cfg.Maximized);
			Glfw.WindowHint(GlfwWindow.Hint.Visible, !cfg.Invisible);


			this.mHandle = Glfw.CreateWindow(cfg.Width, cfg.Height, cfg.Title, null, null);

			if (this.mHandle == null)
			{
				// If a window can't be opened, just crash the program too
				Runtime.FatalError("ERROR: Could not initialize a window");
			}

			Glfw.MakeContextCurrent(this.mHandle);
			GL.Init(=> Glfw.GetProcAddress);

			// Set all the custom GLFW callbacks
			// Close callback
			void closeC(GlfwWindow* window)
			{
				WindowCloseEvent event = scope WindowCloseEvent();
				eventCallback(event);
			}
			Glfw.WindowCloseCallback closeCallback = new => closeC;
			Glfw.SetWindowCloseCallback(this.mHandle, closeCallback);

			// Resize callback
			void sizeC(GlfwWindow* window, int width, int height)
			{
				mSize.X = width;
				mSize.Y = height;
				WindowResizeEvent event = scope WindowResizeEvent(width, height);
				eventCallback(event);
			}	
			Glfw.WindowSizeCallback sizeCallback = new => sizeC;
			Glfw.SetWindowSizeCallback(this.mHandle, sizeCallback);

			// Key callback
			void keyC(GlfwWindow* window, GlfwInput.Key key, int scancode, GlfwInput.Action action, int mods)
			{
				switch (action)
				{
					case GlfwInput.Action.Press:
						KeyPressedEvent event = scope KeyPressedEvent((int)key, 0);
						eventCallback(event);
						break;
					case GlfwInput.Action.Release:
						KeyReleasedEvent event = scope KeyReleasedEvent((int)key);
						eventCallback(event);
						break;
					case GlfwInput.Action.Repeat:
						KeyPressedEvent event = scope KeyPressedEvent((int)key, 1);
						eventCallback(event);
						break;
				}
			}
			Glfw.KeyCallback keyCallback = new => keyC;
			Glfw.SetKeyCallback(this.mHandle, keyCallback);

			// Mouse button callback
			void mouseC(GlfwWindow* window, GlfwInput.MouseButton button, GlfwInput.Action action, int mods)
			{
				switch (action)
				{
					case GlfwInput.Action.Press:
						MouseButtonPressedEvent event = scope MouseButtonPressedEvent((int)button);
						eventCallback(event);
						break;
					case GlfwInput.Action.Release:
						MouseButtonReleasedEvent event = scope MouseButtonReleasedEvent((int)button);
						eventCallback(event);
						break;
					case GlfwInput.Action.Repeat:
						MouseButtonPressedEvent event = scope MouseButtonPressedEvent((int)button);
						eventCallback(event);
						break;
				}
			}
			Glfw.MouseButtonCallback mouseCallback = new => mouseC;
			Glfw.SetMouseButtonCallback(this.mHandle, mouseCallback);

			// Mouse scroll callback
			void mouseScrollC(GlfwWindow* window, double xOffset, double yOffset)
			{
				MouseScrolledEvent event = scope MouseScrolledEvent((float)xOffset, (float)yOffset);
				eventCallback(event);
			}
			Glfw.ScrollCallback scrollCallback = new => mouseScrollC;
			Glfw.SetScrollCallback(this.mHandle, scrollCallback);

			// Mouse movement callback
			void mouseMovementC(GlfwWindow* window, double x, double y)
			{
				MouseMovedEvent event = scope MouseMovedEvent((float)x, (float)y);
				eventCallback(event);
			}
			Glfw.CursorPosCallback mouseMovedCallback = new => mouseMovementC;
			Glfw.SetCursorPosCallback(this.mHandle, mouseMovedCallback);
		}

		public void Update()
		{
			switch(mVSync)
			{
			case true : Glfw.SwapInterval(1);
			case false: Glfw.SwapInterval(0);
			}

			Glfw.PollEvents();
			Glfw.SwapBuffers(mHandle);
		}

		public void Destroy()
		{
			Glfw.DestroyWindow(mHandle);
			Glfw.Terminate();
		}

		// SetTitle changes the title of the Window
		public void SetTitle(StringView title)
		{
			Glfw.SetWindowTitle(mHandle, title);
		}
	}	
}
