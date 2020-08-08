using System;
using imgui_beef;

namespace SteelEditor
{
	public static class EditorGUI
	{
		public static bool Button(StringView name) => ImGui.Button(name.Ptr);

		public static void Text(StringView fmt, params Object[] args) => ImGui.Text(scope String()..AppendF(fmt, params args));
		public static void LabelText(StringView label, StringView fmt, params Object[] args) => ImGui.LabelText(scope String()..AppendF(fmt, params args), label.Ptr);

		public static bool Checkbox(StringView name, bool value)
		{
			bool isChecked = value;
			ImGui.Checkbox(name.Ptr, &isChecked);
			return isChecked;
		}
	}
}
