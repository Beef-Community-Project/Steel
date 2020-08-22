using System;
using System.Collections;
using SteelEngine;
using SteelEngine.Events;
using SteelEngine.Window;
using imgui_beef;
using glfw_beef;

namespace SteelEditor
{
	public class EditorLayer : Layer
	{
		private Window _window;
		private List<EditorWindow> _editorWindows = new .();

		private bool _showDemoWindow = false;

		private String _iniPath = new .() ~ delete _;

		public this(Window window) : base("EditorLayer")
		{
			_window = window;
		}

		public override void OnAttach()
		{
			ImGui.CreateContext();

			SteelPath.GetEditorUserFile("imgui.ini", _iniPath);

			var io = ref ImGui.GetIO();
			io.IniFilename = _iniPath;
			
			var style = ref ImGui.GetStyle();
			style.WindowMenuButtonPosition = .None; // This disables the collapse button on windows
			style.WindowRounding = 0f;
			ImGui.StyleColorsClassic(&style);

			ImGuiImplGlfw.InitForOpenGL(_window.GetHandle, true);
			ImGuiImplOpengl3.Init(=> Glfw.GetProcAddress);

			Log.Trace("OpenGL version: {}", ImGuiImplOpengl3.[Friend]g_GlVersion);
			Log.Trace("GLSL version: {}", ImGuiImplOpengl3.[Friend]g_GlslVersionString);
		}

		public override void OnDetach()
		{
			for (var editorWindow in _editorWindows)
			{
				CloseWindow(editorWindow);
				delete editorWindow;
			}

			delete _editorWindows;

			ImGuiImplOpengl3.Shutdown();
			ImGuiImplGlfw.Shutdown();
			ImGui.DestroyContext();
		}

		public override void OnUpdate()
		{
			var io = ref ImGui.GetIO();
			var app = Application.Instance;
			io.DisplaySize = ImGui.Vec2(app.Window.GetSize.x, app.Window.GetSize.y);
			ImGuiImplOpengl3.NewFrame();
			ImGuiImplGlfw.NewFrame();
			ImGui.NewFrame();

			if (ImGui.BeginMainMenuBar())
			{
				if (ImGui.BeginMenu("File"))
				{
					ImGui.EndMenu();
				}

				if (ImGui.BeginMenu("Edit"))
				{
					ImGui.EndMenu();
				}

				if (ImGui.BeginMenu("Window"))
				{
					for (var window in _editorWindows)
					{
						if (ImGui.MenuItem(window.Title.Ptr))
							ShowWindow(window);
					}

					if (ImGui.MenuItem("Demo"))
						_showDemoWindow = true;

					ImGui.EndMenu();
				}

				ImGui.EndMainMenuBar();
			}

			if (_showDemoWindow)
				ImGui.ShowDemoWindow(&_showDemoWindow);

			// Update ImGui windows
			for (var window in _editorWindows)
			{
				if (!window.IsActive && !window.IsClosed)
					CloseWindow(window);
				else
					window.Update();
			}

			// Background color
			ImGuiImplOpengl3GL.glClearColor(0.45f, 0.55f, 0.60f, 1.00f);
			ImGuiImplOpengl3GL.glClear(ImGuiImplOpengl3GL.GL_COLOR_BUFFER_BIT);

			// ImGui rendering
			ImGui.Render();
			ImGuiImplOpengl3.RenderDrawData(ImGui.GetDrawData());
		}

		public void ShowWindow<T>() where T : EditorWindow
		{
			for (var window in _editorWindows)
			{
				if (window.GetType() == typeof(T))
				{
					ShowWindow(window);
					return;
				}
			}

			var fullTypeName = scope String()..AppendF("{}", typeof(T));
			StringView typeName = StringView("null");
			for (var str in fullTypeName.Split('.'))
				typeName = str;

			Log.Error("{} does not exist in application", typeName);
		}

		public void ShowWindow(StringView windowName)
		{
			for (var window in _editorWindows)
			{
				if (window.Title == windowName)
				{
					ShowWindow(window);
					break;
				}
			}
		}

		public void ShowWindow(EditorWindow window)
		{
			if (!window.IsActive)
			{
				window.IsActive = true;

				if (!window.[Friend]_isInitialized)
				{
					window.OnInit();
					window.[Friend]_isInitialized = true;
				}

				window.OnShow();
				window.IsClosed = false;
			}
		}

		public void AddWindow<T>() where T : EditorWindow
		{
			_editorWindows.Add(new T());
		}

		public void CloseWindow<T>() where T : EditorWindow
		{
			EditorWindow window = GetWindow<T>();

			if (window != null)
				CloseWindow(window);
		}

		public void CloseWindow(EditorWindow window)
		{
			window.IsActive = false;
			window.OnClose();
			window.IsClosed = true;
		}

		public T GetWindow<T>() where T : EditorWindow
		{
			for (var window in _editorWindows)
				if (typeof(T) == window.GetType())
					return window;

			return null;
		}
	}
}