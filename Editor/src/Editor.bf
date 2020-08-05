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
		}

		public override void OnCleanup()
		{
			
		}
	}
}
