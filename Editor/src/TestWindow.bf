using System;
using SteelEngine;

namespace SteelEditor
{
	public class TestWindow : EditorWindow
	{
		public override StringView Title => "Test";

		private bool _isChecked = false;

		public override void OnInit()
		{
			Log.Trace("OnInit()");
		}

		public override void OnRender()
		{
			if (EditorGUI.Button("TestButton"))
				Log.Trace("You hit the test button!");

			EditorGUI.Text("Try hitting this checkbox");

			_isChecked = EditorGUI.Checkbox("Checkbox", _isChecked);

			EditorGUI.LabelText("Value: ", "{}", _isChecked);
		}

		public override void OnClose()
		{
			Log.Trace("OnClose()");
		}
	}
}
