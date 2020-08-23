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
		private static InputCallback _inputCallback = .(.None);
		private static Dictionary<String, InputTextBuffer> _inputTextBuffers = new .() ~ DeleteDictionaryAndKeysAndItems!(_);
		private static bool _popItemWidth = false;
		private static bool _popItemColor = false;
		private static bool _popItemID = false;
		private static uint _collapsableHeaderCount = 0;

		// Window

		public static bool BeginWindow(StringView name, ref bool isActive)
		{
			return ImGui.Begin(name.Ptr, &isActive, .NoScrollbar);
		}

		public static void EndWindow()
		{
			ImGui.End();
		}

		// Text

		public static void Text(StringView fmt, params Object[] args)
		{
			ImGui.Text(scope String()..AppendF(fmt, params args));
			CheckItem();
		}

		public static bool Selectable(StringView text, bool selected = false)
		{
			var isSelected = ImGui.Selectable(text.Ptr, selected);
			CheckItem();
			return isSelected;
		}

		public static bool Label(StringView label)
		{
			if (label.StartsWith("##"))
				return false;

			ImGui.Columns(2);
			ImGui.AlignTextToFramePadding();

			Text(label);
			CheckItem(false);

			ImGui.SameLine(22);
			FillWidth();

			return true;
		}

		public static void LabelText(StringView label, StringView fmt, params Object[] args)
		{
			Label(label);
			Text(scope String()..AppendF(fmt, params args));
			CheckItem(false);
		}

		public static void Tooltip(StringView fmt, params Object[] args)
		{
			ImGui.BeginTooltip();
			Text(fmt, params args);
			ImGui.EndTooltip();
		}

		// Input

		public static bool Button(StringView name)
		{
			var isClicked = ImGui.Button(name.Ptr);
			CheckItem();
			return isClicked;
		}

		public static void Button(StringView name, ref bool value)
		{
			value = Button(name);
		}

		public static void ToggleButton(StringView name, ref bool value)
		{
			if (!value)
			{
				var color = ImGui.GetStyleColorVec4(.Button);
				color.w = 0.2f;
				ImGui.PushStyleColor(.Button, color);
			}

			var isClicked = ImGui.Button(name.Ptr);

			if (!value)
				ImGui.PopStyleColor();

			CheckItem();
			if (isClicked)
				value = !value;
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

		public static InputCallback Input(StringView label, String buffer, StringView hint = "", int maxSize = 256)
		{
			bool hasLabel = Label(label);
			if (!hasLabel)
				ImGui.Columns(1);

			if (_inputCallback.[Friend]_type != .None)
				_inputCallback = .(.None);

			var labelStr = scope String(label);

			if (!_inputTextBuffers.ContainsKey(labelStr))
				_inputTextBuffers[new String(label)] = new .();

			var inputTextBuffer = _inputTextBuffers[labelStr];
			if (inputTextBuffer.Size != (uint) maxSize)
				inputTextBuffer.ReAlloc((uint) maxSize);

			inputTextBuffer.Set(buffer);

			bool isEnter = false;

			ImGui.InputTextFlags flags = .EnterReturnsTrue | .CallbackHistory | .CallbackCompletion;

			if (hint != "")
				isEnter = ImGui.InputTextWithHint(scope UniqueLabel(label, "Input"), hint.Ptr, inputTextBuffer.Ptr, (uint) maxSize, flags, => InputTextCallback);
			else
				isEnter = ImGui.InputText(scope UniqueLabel(label, "Input"), inputTextBuffer.Ptr, (uint) maxSize, flags, => InputTextCallback);
			
			if (!hasLabel)
				CheckItem(false);
			else
				CheckItem();

			var view = inputTextBuffer.View();

			if (view != buffer)
				_inputCallback = .(.OnChange);

			if (isEnter)
				_inputCallback = .(.OnEnter);

			buffer.Set(view);

			return _inputCallback;
		}

		private static int InputTextCallback(ImGui.InputTextCallbackData* data)
		{
			_inputCallback = .(data);
			return 0;
		}

		public static int Int(StringView label, int value)
		{
			var input = value;
			Int(label, ref input);
			return input;
		}

		public static void Int(StringView label, ref int value)
		{
			Label(label);
			ImGui.DragInt(scope UniqueLabel(label, "InputInt"), &value);
			CheckItem();
		}

		public static float Float(StringView label, float value)
		{
			var input = value;
			Float(label, ref input);
			return input;
		}

		public static void Float(StringView label, ref float value)
		{
			Label(label);
			ImGui.DragFloat(scope UniqueLabel(label, "InputFloat"), &value);
			CheckItem();
		}

		public static Vector2 Vector2(StringView label, Vector2 value)
		{
			var input = value;
			Vector2(label, ref input);
			return input;
		}

		public static void Vector2(StringView label, ref Vector2 value)
		{
			Label(label);
			ImGui.DragFloat2(scope UniqueLabel(label, "Vector2"), value.data);
			CheckItem();
		}

		public static Vector3 Vector3(StringView label, Vector3 value)
		{
			var input = value;
			Vector3(label, ref input);
			return input;
		}

		public static void Vector3(StringView label, ref Vector3 value)
		{
			Label(label);
			ImGui.DragFloat3(scope UniqueLabel(label, "Vector3"), value.data);
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
			ImGui.PopStyleColor();
			ImGui.Separator();
			ImGui.PushStyleColor(.Separator, ImGui.Vec4(0, 0, 0, 0));
		}

		public static void SameLine(float offset = 0)
		{
			if (offset != 0)
				ImGui.SameLine(offset);
			else
				ImGui.SameLine();
		}

		public static void AlignFromRight(float offset)
		{
			ImGui.SameLine(ImGui.GetWindowWidth() - offset);
		}

		public static void ItemWidth(float width)
		{
			ImGui.PushItemWidth(width);
			_popItemWidth = true;
		}

		public static void FillWidth() => ItemWidth(-1);

		public static bool BeginCollapsableHeader(StringView label)
		{
			ImGui.Columns(1);
			var isOpen = ImGui.CollapsingHeader(label.Ptr);
			if (isOpen)
			{
				ImGui.Indent();
				_collapsableHeaderCount++;
			}
			else
			{
				CheckItem(false);
			}
			return isOpen;
		}

		public static void EndCollapsableHeader()
		{
			if (_collapsableHeaderCount > 0)
			{
				CheckItem(false);
				ImGui.Unindent();
				ImGui.Columns(2);
				_collapsableHeaderCount--;
			}
		}

		public static bool BeginTree(StringView label)
		{
			return ImGui.TreeNode(label.Ptr);
		}

		public static void EndTree()
		{
			ImGui.TreePop();
		}

		public static void BeginScrollingRegion(StringView label, float height = 0)
		{
			ImGui.BeginChild(label.Ptr, .(0, height), false, .HorizontalScrollbar);
		}

		public static void EndScrollingRegion()
		{
			ImGui.EndChild();
		}

		public static float GetHeightOfItems(uint numberOfItems)
		{
			return ImGui.GetStyle().ItemSpacing.y + ImGui.GetFrameHeightWithSpacing() * numberOfItems;
		}

		// Style

		public static void TextColor(Color color)
		{
			ImGui.PushStyleColor(.Text, color);
			_popItemColor = true;
		}

		// Other

		public static void ItemID(StringView id)
		{
			ImGui.PushID(id.Ptr);
			_popItemID = true;
		}

		private static void CheckItem(bool nextColumn = true)
		{
			if (_popItemWidth)
			{
				ImGui.PopItemWidth();
				_popItemWidth = false;
			} 
			
			if (_popItemColor)
			{
				ImGui.PopStyleColor();
				_popItemColor = false;
			}

			if (_popItemID)
			{
				ImGui.PopID();
				_popItemID = false;
			}

			if (nextColumn)
				ImGui.NextColumn();
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

			public uint Size = 0;

			public this(uint size = 1)
			{
				ReAlloc(size);
			}

			public ~this()
			{
				if (_buffer != null)
					delete _buffer;
			}

			public void Set(StringView str)
			{
				if (str.Length > (int) Size)
					return;
				for (int i = 0; i < str.Length; i++)
					_buffer[i] = str[i];
				for (int i = str.Length; i < (int) Size; i++)
					_buffer[i] = '\0';
			}

			public void ReAlloc(uint size)
			{
				if (size == Size)
					return;

				Size = size;

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

		public enum InputCallbackType
		{
			None,
			OnHistory,
			OnEnter,
			OnCompletion,
			OnChange
		}

		public struct InputCallback
		{
			private InputCallbackType _type;
			private VerticalDirection _historyDirection = .Up;

			public this(InputCallbackType type)
			{
				_type = type;
			}

			public this(ImGui.InputTextCallbackData* data)
			{
				if (data.EventFlag == .CallbackHistory)
				{
					_type = .OnHistory;
					if (data.EventKey == ImGui.Key.DownArrow)
						_historyDirection = .Down;
				}
				else if (data.EventFlag == .EnterReturnsTrue)
				{
					_type = .OnEnter;
				}
				else if (data.EventFlag == .CallbackCompletion)
				{
					_type = .OnCompletion;
				}
				else
				{
					_type = .OnChange;
				}
			}

			public bool OnHistory(out VerticalDirection direction)
			{
				direction = _historyDirection;
				if (_type == .OnHistory)
					return true;
				return false;
			}

			public bool OnEnter => _type == .OnEnter;
			public bool OnCompletion => _type == .OnCompletion;
			public bool OnChange => _type == .OnChange;
		}
	}
}
