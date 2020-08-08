using System;
using System.Collections;
using SteelEngine;
using SteelEngine.Events;
using SteelEngine.Window;
using imgui_beef;
using glfw_beef;

namespace SteelEditor
{
	public class ImGuiLayer : Layer
	{
		private float _time = 0.0f;

		private Window _window;
		private List<EditorWindow> _editorWindows = new .();

		public this(Window window) : base("ImGuiLayer")
		{
			_window = window;
		}

		public override void OnAttach()
		{
			ImGui.CreateContext();

			var style = ref ImGui.GetStyle();
			style.WindowMenuButtonPosition = .None;
			ImGui.StyleColorsClassic(&style);

			ImGuiImplGlfw.InitForOpenGL(_window.GetHandle, false);
			ImGuiImplOpengl3.ImGui_ImplOpenGL3_Init(=> Glfw.GetProcAddress);

			Log.Trace("OpenGL version: {}", ImGuiImplOpengl3.[Friend]g_GlVersion);
			Log.Trace("GLSL version: {}", ImGuiImplOpengl3.[Friend]g_GlslVersionString);
		}

		public override void OnDetach()
		{
			for (var editorWindow in _editorWindows)
			{
				editorWindow.OnClose();
				delete editorWindow;
			}

			delete _editorWindows;

			ImGuiImplOpengl3.ImGui_ImplOpenGL3_Shutdown();
			ImGui.DestroyContext();
		}

		public override void OnUpdate()
		{
			var io = ref ImGui.GetIO();
			var app = Application.Instance;
			io.DisplaySize = ImGui.Vec2(app.Window.GetSize.X, app.Window.GetSize.Y);
			ImGuiImplOpengl3.ImGui_ImplOpenGL3_NewFrame();
			ImGuiImplGlfw.NewFrame();
			ImGui.NewFrame();

			// Should be changed to use Steel DeltaTime
			float time = (float) Glfw.GetTime();
			io.DeltaTime = _time > 0.0f ? (time - _time) : (1.0f / 60.0f);
			_time = time;

			for (var editorWindow in _editorWindows)
			{
				if (editorWindow.IsActive)
					editorWindow.Update();
				else
					CloseWindow(editorWindow);
			}

			ImGui.Render();
			ImGuiImplOpengl3GL.glClearColor(0.45f, 0.55f, 0.60f, 1.00f);
			ImGuiImplOpengl3GL.glClear(ImGuiImplOpengl3GL.GL_COLOR_BUFFER_BIT);
			ImGuiImplOpengl3.ImGui_ImplOpenGL3_RenderDrawData(ImGui.GetDrawData());
		}

		public override void OnEvent(Event event)
		{
			
		}

		public void AddWindow(EditorWindow window)
		{
			_editorWindows.Add(window);
		}

		public void CloseWindow(EditorWindow window)
		{
			window.OnClose();
			_editorWindows.Remove(window);
			delete window;
		}
	}
}