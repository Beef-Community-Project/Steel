using System;
using System.Collections;
using System.IO;
using SteelEngine;
using ImGui;

namespace SteelEditor.Windows
{
	public class StyleWindow : EditorWindow
	{
		public override StringView Title => "Style";

		private int32 _currentTheme = -1;
		private List<String> _themes = new .() ~ DeleteContainerAndItems!(_);

		public override void OnShow()
		{
			LoadThemes();
		}

		public override void OnRender()
		{
			EditorGUI.RemoveColumns();
			if (EditorGUI.Button("Save"))
				Editor.SaveConfig();

			EditorGUI.SameLine();
			if (EditorGUI.Button("Reload"))
				Editor.LoadConfig();

			EditorGUI.SameLine();
			if (EditorGUI.Button("Reset"))
			{
				Editor.ResetStyle();
				_currentTheme = -1;
			}

			if (EditorGUI.Combo("Theme:", _themes, ref _currentTheme))
				Editor.SetTheme(_themes[_currentTheme]);

			if (EditorGUI.BeginCollapsableHeader("Style"))
			{
				ImGui.ShowStyleEditor();
				EditorGUI.EndCollapsableHeader();
			}
		}

		private void LoadThemes()
		{
			DeleteAndClearItems!(_themes);

			String _themesPath = scope .();
			SteelPath.GetEditorResourcePath(_themesPath, "Themes");

			for (var themeFile in Directory.EnumerateFiles(_themesPath))
			{
				String fileName = scope .();
				String themeName = new .();

				themeFile.GetFileName(fileName);
				Path.GetFileNameWithoutExtension(fileName, themeName);
				_themes.Add(themeName);
			}
		}
	}
}
