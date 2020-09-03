using System;
using System.IO;
using SteelEngine;

namespace SteelEditor.Windows
{
	public class NewProjectWindow : EditorWindow
	{
		public override StringView Title => "New Project";

		private String _projectName = new .() ~ delete _;
		private String _projectPath = new .() ~ delete _;

		private const int BROWSE_BUTTON_OFFSET = 59;
		private const int PATH_WIDTH = -60;
		private const int CREATE_BUTTON_WIDTH = 65;
		private const int CREATE_BUTTON_HEIGHT = 20;

		public override void OnShow()
		{
			_projectName.Clear();
			_projectPath.Clear();
		}

		public override void OnRender()
		{
			EditorGUI.RemoveColumns();

			EditorGUI.Label("Name", true);
			EditorGUI.Input("##NewProjectName", _projectName, "", 256, false);

			EditorGUI.Label("Path", true);

			EditorGUI.ItemWidth(PATH_WIDTH);
			EditorGUI.Input("##NewProjectPath", _projectPath, "", 256, true);

			EditorGUI.SameLine();
			EditorGUI.AlignFromRight(BROWSE_BUTTON_OFFSET);
			if (EditorGUI.Button("Browse"))
			{
				var dialog = scope FolderBrowserDialog();
				var dialogResult = dialog.ShowDialog();

				if (dialogResult case .Err)
					Log.Error("Could not show folder browser dialog");

				if (dialogResult.Get() == .OK)
				{
					_projectPath.Set(dialog.SelectedPath);
					if (_projectName.IsEmpty)
					{
						var _projectDirName = scope String();
						Path.GetFileName(_projectPath, _projectDirName);
						_projectName.Set(_projectDirName);
					}	
				}
			}

			EditorGUI.NewLine();
			EditorGUI.AlignMiddle(65);
			if (EditorGUI.Button("Create", .(CREATE_BUTTON_WIDTH, CREATE_BUTTON_HEIGHT)))
			{
				CreateProject();
				IsActive = false;
			}
		}

		private void CreateProject()
		{
			Log.Info("Creating project '{}' at '{}'", _projectName, _projectPath);


		}
	}
}
