using SteelEngine;
using SteelEngine.Events;
using imgui_beef;
using glfw_beef;
using SteelEngine.Window;
using System;

namespace SteelEditor
{
	public class ImGuiLayer : Layer
	{
		static bool show = true;
		private float _time = 0.0f;

		private Window _window;

		public this(Window window) : base("ImGuiLayer")
		{
			_window = window;
		}

		public override void OnAttach()
		{
			ImGui.CreateContext();
			ImGui.StyleColorsDark();

			
			ImGuiImplGlfw.InitForOpenGL(_window.GetHandle, false);

			ImGuiImplOpengl3.ImGui_ImplOpenGL3_Init(=> Glfw.GetProcAddress);
		}

		public override void OnDetach()
		{
			ImGuiImplOpengl3.ImGui_ImplOpenGL3_Shutdown();
			//ImGuiImplGlfw.Shutdown();
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

			float time = (float) Glfw.GetTime();
			io.DeltaTime = _time > 0.0f ? (time - _time) : (1.0f / 60.0f);
			_time = time;

			ImGui.ShowDemoWindow(&show);

			if (ImGui.Begin("test", &show))
			{
				ImGui.Checkbox("Bop", &show);
				ImGui.End();
			}

			ImGui.EndFrame();
			ImGui.Render();
			ImGuiImplOpengl3GL.glClearColor(0.45f, 0.55f, 0.60f, 1.00f);
			ImGuiImplOpengl3GL.glClear(ImGuiImplOpengl3GL.GL_COLOR_BUFFER_BIT);
			ImGuiImplOpengl3.ImGui_ImplOpenGL3_RenderDrawData(ImGui.GetDrawData());
		}

		public override void OnEvent(Event event)
		{
			
		}
	}
}