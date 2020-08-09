using System;
using SteelEngine;

namespace SteelEditor
{
	public class TestWindow : EditorWindow
	{
		public override StringView Title => "Test";

		private bool _isChecked = false;

		private String _previousTextInput = new String() ~ delete _;

		private int _intInput = 0;

		public override void OnRender()
		{
			if (EditorGUI.Button("TestButton"))
				Log.Trace("You hit the test button!");

			EditorGUI.Text("Try hitting this checkbox");

			_isChecked = EditorGUI.Checkbox("Checkbox", _isChecked);

			EditorGUI.LabelText("Value: ", "{}", _isChecked);

			String textInput = scope String();
			EditorGUI.InputText("InputText", textInput);
			if (textInput != _previousTextInput)
			{
				Log.Trace("Input: {}", textInput);
				_previousTextInput.Set(textInput);
			}

			#unwarn
			EditorGUI.InputInt("InputInt", ref _intInput);
		}
	}
}
