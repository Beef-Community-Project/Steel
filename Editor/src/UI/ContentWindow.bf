using System;
using System.IO;
using SteelEngine;
using ImGui;

namespace SteelEditor.UI
{
	public class ContentWindow : EditorWindow
	{
		public override StringView Title => "Content";

		private String _localContentPath = new .() ~ delete _;
		private String _dirPathBuffer = new .() ~ delete _;
		private String _dirNameBuffer = new .() ~ delete _;

		public override void OnShow()
		{
			_dirPathBuffer.Set(SteelPath.ContentDirectory);
			_localContentPath.Set("Content / ");
		}

		public override void OnRender()
		{
			if (SteelPath.ContentDirectory.IsEmpty)
				return;

			_dirPathBuffer.Set(SteelPath.ContentDirectory);
			EditorGUI.Text(_localContentPath);
			ImGui.BeginChild("##ContentTreeView", .(ImGui.GetContentRegionAvail().x / 4f, ImGui.GetContentRegionAvail().y), true);
			if (!SteelPath.ContentDirectory.IsEmpty)
				ShowTree();
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
				if (EditorGUI.Selectable(fileName))
				{
					var filePath = scope String();
					file.GetFilePath(filePath);
					InspectorWindow.ViewFile(filePath);
				}
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
