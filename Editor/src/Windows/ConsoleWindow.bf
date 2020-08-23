using System;
using System.IO;
using System.Collections;
using SteelEngine;
using SteelEngine.Math;
using SteelEngine.Console;
using SteelEditor;
using imgui_beef;

namespace SteelEditor.Windows
{
	public class ConsoleWindow : EditorWindow
	{
		public override StringView Title => "Console";

		public Color TraceColor = .(0.45f, 0.45f, 0.45f, 1f);
		public Color WarningColor = .(0.93f, 0.82f, 0.01f, 1f);
		public Color ErrorColor = .(0.952f, 0.2f, 0.011f, 1f);

		private String _commandBuffer = new .() ~ delete _;

		private bool _scrollToBottom = false;

		private int _commandStartIndex = 0;
		private int _commandIndex = 0;
		private int _newCommandIndex = 1;
		private int _lastLogCount = 0;

		private bool _showErrors = true;
		private bool _showWarnings = true;
		private bool _showInfo = true;
		private bool _showTrace = true;

		private const float CLEAR_BUTTON_OFFSET = 55;

		public override void OnRender()
		{
			EditorGUI.ToggleButton("Errors", ref _showErrors);

			EditorGUI.AlignFromRight(CLEAR_BUTTON_OFFSET);
			if (EditorGUI.Button("Clear"))
				GameConsole.Instance.Clear();

			EditorGUI.ToggleButton("Warnings", ref _showWarnings);
			EditorGUI.ToggleButton("Info", ref _showInfo);
			EditorGUI.ToggleButton("Trace", ref _showTrace);

			var footerSpacing = EditorGUI.GetHeightOfItems(1);
			EditorGUI.BeginScrollingRegion("CommandScrollingRegion", -footerSpacing);

			for (var line in GameConsole.Instance.[Friend]_lines)
			{
				if (!_showErrors && line.level == .Error ||
					!_showWarnings && line.level == .Warning ||
					!_showInfo && line.level == .Info ||
					!_showTrace && line.level == .Trace)
					continue;

				bool hasColor = true;
				Color color = .();

				switch (line.level)
				{
				case .Trace:
					color = TraceColor;
					break;
				case .Warning:
					color = WarningColor;
					break;
				case .Error:
					color = ErrorColor;
					break;
				default:
					hasColor = false;
				}

				if (hasColor)
					EditorGUI.TextColor(color);

				EditorGUI.Text(line.message);
			}

			if (_lastLogCount != GameConsole.Instance.[Friend]_lines.Count)
			{
				_lastLogCount = GameConsole.Instance.[Friend]_lines.Count;
				_scrollToBottom = true;
			}

			if (_scrollToBottom)
			    ImGui.SetScrollHereY(1.0f);
			_scrollToBottom = false;

			EditorGUI.EndScrollingRegion();
			
			EditorGUI.Line();
			EditorGUI.FillWidth();
			var inputCallback = EditorGUI.Input(scope String()..AppendF("##CommandInputBuffer_{}", _commandIndex), _commandBuffer, "", 256);
			if (inputCallback.OnEnter && !_commandBuffer.IsEmpty)
			{
				ImGui.SetKeyboardFocusHere(-1);
				_scrollToBottom = true;

				GameConsole.Instance.Enqueue(_commandBuffer);
				ClearCommandBuffer();
			}
			else if (inputCallback.OnHistory(let direction))
			{
				OnCommandHistory(direction);
			}
		}

		private void OnCommandHistory(VerticalDirection dir)
		{
			if (dir == .Up && _commandIndex > _commandStartIndex)
				_commandIndex--;
			else if (_commandIndex < _newCommandIndex)
				_commandIndex++;

			ImGui.SetKeyboardFocusHere(-1);
		}

		public void ClearCommands()
		{
			_commandStartIndex = _newCommandIndex;
			_commandIndex = _commandStartIndex;
		}

		public void ClearCommandBuffer()
		{
			_commandIndex = _newCommandIndex;
			_newCommandIndex++;
		}

		private enum ConsoleType
		{
			Log,
			Game
		}
	}
}
