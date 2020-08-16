using System;
using System.Collections;
using imgui_beef;
using SteelEngine;
using SteelEngine.Math;
using SteelEngine.Input;

namespace SteelEditor
{
	public static class EditorGUI
	{
		public delegate void HistoryCallback(VerticalDirection direction);

		private static HistoryCallback _historyCallback = null;
		private static Dictionary<String, InputTextBuffer> _inputTextBuffers = new .() ~ DeleteDictionaryAndKeysAndItems!(_);
		private static uint _popItemWidthCount = 0;

		// Text

		public static void Text(StringView fmt, params Object[] args)
		{
			ImGui.Text(scope String()..AppendF(fmt, params args));
			CheckItem();
		}

		public static void Label(StringView label)
		{
			if (label.StartsWith("##"))
				return;

			ImGui.AlignTextToFramePadding();
			Text(label);
			CheckItem();
			ImGui.SameLine();
		}

		public static void LabelText(StringView label, StringView fmt, params Object[] args)
		{
			ImGui.LabelText(scope String()..AppendF(fmt, params args), label.Ptr);
			CheckItem();
		}

		// Input

		public static bool Button(StringView name)
		{
			var isClicked = ImGui.Button(name.Ptr);
			CheckItem();
			return isClicked;
		}

		public static bool Checkbox(StringView label, bool value)
		{
			bool isChecked = value;
			Checkbox(label, ref isChecked);

			return isChecked;
		}

		public static void Checkbox(StringView label, ref bool value)
		{
			Label(label);
			ImGui.Checkbox(scope UniqueLabel(label, "Checkbox"), &value);
			CheckItem();
		}

		public static bool Input(StringView label, String buffer, StringView hint = "", uint maxSize = 256, HistoryCallback historyCallback = null)
		{
			Label(label);

			_historyCallback = historyCallback;
			var labelStr = scope String(label);

			if (!_inputTextBuffers.ContainsKey(labelStr))
				_inputTextBuffers[new String(label)] = new .();

			var inputTextBuffer = _inputTextBuffers[labelStr];
			inputTextBuffer.ReAlloc(maxSize);

			bool enterPressed = false;

			ImGui.InputTextFlags flags = .EnterReturnsTrue | .CallbackHistory;

			if (hint != "")
				enterPressed = ImGui.InputTextWithHint(scope UniqueLabel(label, "Input"), hint.Ptr, inputTextBuffer.Ptr, maxSize, flags, => InputTextCallback);
			else
				enterPressed = ImGui.InputText(scope UniqueLabel(label, "Input"), inputTextBuffer.Ptr, maxSize, flags, => InputTextCallback);

			CheckItem();
			buffer.Set(inputTextBuffer.View());
			_historyCallback = null;

			return enterPressed;
		}

		private static int InputTextCallback(ImGui.InputTextCallbackData* data)
		{
			if (data.EventFlag == .CallbackHistory)
			{
				if (_historyCallback == null)
					return 0;

				VerticalDirection dir = .Up;
				if (data.EventKey == ImGui.Key.DownArrow)
					dir = .Down;
				_historyCallback(dir);
			}

			return 0;
		}

		public static int InputInt(StringView label, int value)
		{
			var input = value;
			InputInt(label, ref input);
			return input;
		}

		public static void InputInt(StringView label, ref int value)
		{
			Label(label);
			ImGui.InputInt(scope UniqueLabel(label, "InputInt"), &value);
			CheckItem();
		}

		public static float InputFloat(StringView label, float value)
		{
			var input = value;
			InputFloat(label, ref input);
			return input;
		}

		public static void InputFloat(StringView label, ref float value)
		{
			Label(label);
			ImGui.InputFloat(scope UniqueLabel(label, "InputFloat"), &value);
			CheckItem();
		}

		public static double InputDouble(StringView label, double value)
		{
			var input = value;
			InputDouble(label, ref input);
			return input;
		}

		public static void InputDouble(StringView label, ref double value)
		{
			Label(label);
			ImGui.InputDouble(scope UniqueLabel(label, "InputDouble"), &value);
			CheckItem();
		}

		public static Vector2 InputVector2(StringView label, Vector2 value)
		{
			var input = value;
			InputVector2(label, ref input);
			return input;
		}

		public static void InputVector2(StringView label, ref Vector2 value)
		{
			Label(label);
			ImGui.InputFloat2(scope UniqueLabel(label, "InputVector2"), value.data);
			CheckItem();
		}

		public static Vector3 InputVector3(StringView label, Vector3 value)
		{
			var input = value;
			InputVector3(label, ref input);
			return input;
		}

		public static void InputVector3(StringView label, ref Vector3 value)
		{
			Label(label);
			ImGui.InputFloat3(scope UniqueLabel(label, "InputVector3"), value.data);
			CheckItem();
		}

		public static void SliderFloat(StringView label, ref float value, float minValue, float maxValue)
		{
			Label(label);
			ImGui.SliderFloat(scope UniqueLabel(label, "SliderFloat"), &value, minValue, maxValue);
			CheckItem();
		}

		public static bool Combo<TEnum>(StringView label, ref TEnum currentItem)
			where TEnum : Enum
		    where int : operator explicit TEnum
		    where TEnum : operator explicit int
		{
		    Label(label);

		    var enumItems = scope List<char8*>();
		    for (var item in typeof(TEnum).GetFields())
		        enumItems.Add(item.Name.Ptr);

		    var str = scope String();
		    for (var item in enumItems)
		        str.AppendF("{}\0", StringView(item));

		    int tmp = (.) currentItem;

		    let result = ImGui.Combo(scope UniqueLabel(label, "Combo"), &tmp, str);
			CheckItem();
		    currentItem = (.) tmp;
		    return result;
		}

		// Layout

		public static void Line()
		{
			ImGui.Separator();
		}

		public static void SameLine()
		{
			ImGui.SameLine();
		}

		public static void ItemWidth(float percent)
		{
			//let windowWidth = ImGui.GetWindowContentRegionWidth();
			//ImGui.PushItemWidth(windowWidth / 100 * percent);
			ImGui.PushItemWidth(-50);
			_popItemWidthCount++;
		}

		// Other

		public static void Tooltip(StringView fmt, params Object[] args)
		{
			ImGui.BeginTooltip();
			Text(fmt, params args);
			ImGui.EndTooltip();
		}

		private static void CheckItem()
		{
			if (_popItemWidthCount > 0)
			{
				ImGui.PopItemWidth();
				_popItemWidthCount--;
			}
		}

		private class UniqueLabel
		{
			public String ID ~ delete _;

			public this(StringView label, StringView widget, params Object[] seeds)
			{
				ID = new String()..AppendF("##{}_{}", label, widget);
				var enumerator = seeds.GetEnumerator();
				for (var seed in enumerator)
				{
					if (enumerator.[Friend]mIndex < enumerator.[Friend]mList.Length)
						ID.AppendF("{}_", seed);
					else
						ID.AppendF("{}", seed);
				}
			}

			public static implicit operator char8*(Self uniqueLabel)
			{
			    if (uniqueLabel == null)
					return null;

				return uniqueLabel.ID;
			}
		}

		private class InputTextBuffer
		{
			private char8[] _buffer = null;
			private uint _size = 0;

			public this(uint size = 1)
			{
				ReAlloc(size);
			}

			public ~this()
			{
				if (_buffer != null)
					delete _buffer;
			}

			public void ReAlloc(uint size)
			{
				if (size == _size)
					return;

				_size = size;

				if (_buffer != null)
				{
					var newBuffer = new char8[size];
					_buffer.CopyTo(newBuffer);
					delete _buffer;
					_buffer = newBuffer;
				}
				else
				{
					_buffer = new char8[size];
				}
			}

			public override void ToString(String strBuffer)
			{
				strBuffer.Append(StringView(Ptr));
			}

			public StringView View() => StringView(Ptr);

			public char8* Ptr => &_buffer[0];
		}
	}
}
