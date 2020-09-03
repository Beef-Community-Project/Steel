using System;
using SteelEngine;

namespace SteelEditor.Windows
{
	public class PropertiesWindow : EditorWindow
	{
		private String _title = new .() ~ delete _;
		public override StringView Title => _title;

		public override void OnShow()
		{
			_title.Clear();
			_title.AppendF("Properties - {}", Application.GetInstance<Editor>().CurrentProject.Name);
		}
	}
}
