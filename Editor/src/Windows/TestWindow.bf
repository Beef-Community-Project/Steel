using System;
using System.Collections;
using SteelEngine;

namespace SteelEditor.Windows
{
	public class TestWindow : EditorWindow
	{
		public override StringView Title => "Test";

		private bool _isChecked = false;

		private String _textInput = new String() ~ delete _;
		private String _hintTextInput = new String() ~ delete _;
		private int _intInput = 0;
		private Vector2 _vector2Input;
		private Vector3 _vector3Input;
		private ComboItem _comboItem = .Item1;

		public override void OnRender()
		{
			if (EditorGUI.Button("TestButton"))
				Log.Trace("You hit the test button!");

			EditorGUI.Text("Try hitting this checkbox");

			_isChecked = EditorGUI.Checkbox("Checkbox", _isChecked);
			if (_isChecked)
				EditorGUI.Text("Checked!");

			EditorGUI.Input("Input", _textInput);

			EditorGUI.Input("Input with hint", _hintTextInput, "Enter text here");

			EditorGUI.Int("Int", ref _intInput);

			EditorGUI.Vector2("Vector2", ref _vector2Input);
			EditorGUI.Vector3("Vector3", ref _vector3Input);

			EditorGUI.Combo<ComboItem>("Combo", ref _comboItem);
		}

		private enum ComboItem
		{
			Item1,
			Item2,
			Item3
		}
	}
}
