/*using System;
using System.IO;
using SteelEngine;
using SteelEditor.Extensions;
using ImGui;

namespace SteelEditor.UI
{
	public class ExtensionsWindow : EditorWindow
	{
		public override StringView Title => "Extensions";

		private String _searchBuffer = new .() ~ delete _;

		public override void OnRender()
		{
			EditorGUI.FillWidth();
			EditorGUI.Input("##ExtensionsSearch", _searchBuffer, "Search...");

			for (var name in Extensions.[Friend]_extensionNames)
			{
				if (name.StartsWith(_searchBuffer))
				{
					var bgColor = ImGui.GetStyleColorVec4(.WindowBg);
					const float colorDecrease = 0.015f;
					bgColor.x = (bgColor.x - colorDecrease) >= 0f ? bgColor.x - colorDecrease : 0;
					bgColor.y = (bgColor.y - colorDecrease) >= 0f ? bgColor.y - colorDecrease : 0;
					bgColor.z = (bgColor.z - colorDecrease) >= 0f ? bgColor.z - colorDecrease : 0;
					ImGui.PushStyleColor(.ChildBg, bgColor);
					ImGui.BeginChild(scope String()..AppendF("##{}_Frame", name), .(0, 20), false, .NoScrollbar);

					ImGui.Indent(10);
					EditorGUI.Label(name);
					EditorGUI.AlignFromRight(20);
					EditorGUI.Checkbox(scope String()..AppendF("##{}_Checkbox", name), true);
					ImGui.Unindent();

					ImGui.EndChild();
					ImGui.PopStyleColor();
				}
			}
		}
	}
}*/
