using System;
using imgui_beef;

namespace SteelEditor
{
	public static class EditorGUI
	{
		public static bool Button(StringView name) => ImGui.Button(name.Ptr);

		// Text

		public static void Text(StringView fmt, params Object[] args) => ImGui.Text(scope String()..AppendF(fmt, params args));
		public static void LabelText(StringView label, StringView fmt, params Object[] args) => ImGui.LabelText(scope String()..AppendF(fmt, params args), label.Ptr);

		// Input

		public static bool Checkbox(StringView name, bool value)
		{
			bool isChecked = value;
			ImGui.Checkbox(name.Ptr, &isChecked);

			return isChecked;
		}

		public static void InputText(StringView label, String buffer, int maxSize = 128)
		{
			char8[] rawBuffer = new char8[maxSize];
			buffer.Reserve(maxSize);
			ImGui.InputText(label.Ptr, &rawBuffer[0], (uint) maxSize);
			buffer.Set(StringView(&rawBuffer[0]));
			delete rawBuffer;
		}

		public static int InputInt(StringView label, int value)
		{
			int input = value;
			InputInt(label, ref input);
			return input;
		}

		public static void InputInt(StringView label, ref int value)
		{
			ImGui.InputInt(label.Ptr, &value);
		}
	}
}
