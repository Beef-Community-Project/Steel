using System;
using imgui_beef;

namespace SteelEditor.Windows
{
	public class StyleWindow : EditorWindow
	{
		public override StringView Title => "Style";

		public override void OnRender()
		{
			EditorGUI.AlignFromRight(60);
			if (EditorGUI.Button("Save"))
				Editor.SaveConfig();

			ImGui.ShowStyleEditor();
		}
	}
}
