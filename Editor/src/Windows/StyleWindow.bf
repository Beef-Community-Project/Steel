using System;
using imgui_beef;

namespace SteelEditor.Windows
{
	public class StyleWindow : EditorWindow
	{
		public override StringView Title => "Style";

		public override void OnRender()
		{
			EditorGUI.AlignFromRight(170);
			if (EditorGUI.Button("Reset"))
				Editor.ResetStyle();

			EditorGUI.SameLine();
			if (EditorGUI.Button("Reload"))
				Editor.LoadConfig();

			EditorGUI.SameLine();
			if (EditorGUI.Button("Save"))
				Editor.SaveConfig();

			ImGui.ShowStyleEditor();
		}
	}
}
