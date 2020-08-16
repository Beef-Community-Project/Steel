using System;
using imgui_beef;

namespace SteelEditor.Windows
{
	public class StyleWindow : EditorWindow
	{
		public override StringView Title => "Style";

		public override void OnRender()
		{
			ImGui.ShowStyleEditor();

			if (EditorGUI.Button("Save"))
				Editor.SaveConfig();
		}
	}
}
