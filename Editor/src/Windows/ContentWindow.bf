using System;
using System.IO;
using SteelEngine;
using imgui_beef;

namespace SteelEditor.Windows
{
	public class ContentWindow : EditorWindow
	{
		public override StringView Title => "Content";

		private String _dirPathBuffer = new .() ~ delete _;
		private String _dirNameBuffer = new .() ~ delete _;

		public override void OnRender()
		{
			ImGui.BeginChild("##TreeView", .(ImGui.GetContentRegionAvail().x / 4f, ImGui.GetContentRegionAvail().y), true);
			if (!SteelPath.ContentDirectory.IsEmpty)
			{
				_dirPathBuffer.Set(SteelPath.ContentDirectory);
				ShowTree();
			}
			ImGui.EndChild();

			EditorGUI.SameLine();

			ImGui.BeginChild("##DirectoryView", .(ImGui.GetContentRegionAvail().x, ImGui.GetContentRegionAvail().y), true);


			ImGui.EndChild();
		}

		private void ShowTree()
		{
			for (var file in Directory.EnumerateFiles(_dirPathBuffer))
			{
				var fileName = scope String();
				file.GetFileName(fileName);
				EditorGUI.Selectable(fileName);
			}

			for (var subDir in Directory.EnumerateDirectories(_dirPathBuffer))
			{
				_dirPathBuffer.Clear();
				subDir.GetFilePath(_dirPathBuffer);

				_dirNameBuffer.Clear();
				subDir.GetFileName(_dirNameBuffer);

				if (EditorGUI.BeginTree(_dirNameBuffer))
				{
					ShowTree();
					EditorGUI.EndTree();
				}
			}
		}
	}
}
