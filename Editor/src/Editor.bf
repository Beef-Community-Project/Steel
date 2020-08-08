using SteelEngine;
using SteelEngine.Window;
using imgui_beef;

namespace SteelEditor
{
	public class Editor : Application
	{
		private ImGuiLayer _imGuiLayer;

		public override void OnInit()
		{
			_imGuiLayer = new .(Window);
			PushOverlay(_imGuiLayer);

			// SpawnWindow<TestWindow>();
		}

		public override void OnCleanup()
		{
			
		}

		public void SpawnWindow<T>() where T : EditorWindow
		{
			var window = new T();
			window.OnInit();
			_imGuiLayer.AddWindow(window);
		}
	}
}
