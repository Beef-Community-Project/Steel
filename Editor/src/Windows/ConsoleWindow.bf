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

		public ImGui.Vec4 TraceColor = .(0.603f, 0.603f, 0.035f, 1f);
		public ImGui.Vec4 WarningColor = .(0.93f, 0.82f, 0.01f, 1f);
		public ImGui.Vec4 ErrorColor = .(0.952f, 0.2f, 0.011f, 1f);

		private String _commandBuffer = new .() ~ delete _;
		private List<(String str, LogLevel level)> _log = new .() ~ { ClearLog(); delete _log; };

		private bool _scrollToBottom = false;
		private LogLevel _minLogLevel = .Trace;
		private ConsoleType _consoleType = .Log;
		private GameConsole _gameConsole = new .() ~ delete _;

		private int _commandStartIndex = 0;
		private int _commandIndex = 0;
		private int _newCommandIndex = 1;

		private EditorGUI.HistoryCallback _historyCallback = new => OnCommandHistoryChange ~ delete _;

		private const float consoleComboWidth = 86;
		private const float clearButtonOffset = 55;
		private const float levelComboWidth   = 100;

		public override void OnInit()
		{
			Log.AddCallback(new (str, level) => _log.Add((new String(str), level)));
		}

		public override void OnRender()
		{
			ImGui.PushItemWidth(consoleComboWidth);
			EditorGUI.Combo<ConsoleType>("Console:", ref _consoleType);
			ImGui.PopItemWidth();

			ImGui.SameLine(ImGui.GetWindowWidth() - clearButtonOffset);
			if (EditorGUI.Button("Clear"))
				Clear();

			ImGui.PushItemWidth(levelComboWidth);
			EditorGUI.Combo<LogLevel>("Level:", ref _minLogLevel);
			ImGui.PopItemWidth();

			var footerSpacing = ImGui.GetStyle().ItemSpacing.y + ImGui.GetFrameHeightWithSpacing();
			ImGui.BeginChild("CommandScrollingRegion", .(0, -footerSpacing), false, .HorizontalScrollbar);

			if (_consoleType == .Game)
			{
				for (int i = _commandStartIndex; i < _gameConsole.History.Count; i++)
					ImGui.Text(scope String()..AppendF("> {}\n", StringView(_gameConsole.History.AtIndex(i))));
			}
			else
			{
				for (var message in _log)
				{
					if (message.level < _minLogLevel)
						continue;

					bool hasColor = true;
					ImGui.Vec4 color = .();

					switch (message.level)
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

					ImGui.PushStyleColor(.Text, color);
					ImGui.TextUnformatted(message.str.Ptr);
					ImGui.PopStyleColor();
				}
			}

			if (_scrollToBottom)
			    ImGui.SetScrollHereY(1.0f);
			_scrollToBottom = false;

			ImGui.EndChild();
			
			EditorGUI.Line();
			ImGui.PushItemWidth(-10);
			if (EditorGUI.Input(scope String()..AppendF("##CommandInputBuffer_{}", _commandIndex), _commandBuffer, "", 256, _historyCallback) && !_commandBuffer.IsEmpty)
			{
				_consoleType = .Game;
				_gameConsole.History.Add(_commandBuffer);

				ImGui.SetKeyboardFocusHere(-1);
				_scrollToBottom = true;

				_gameConsole.Execute(_commandBuffer);
				ClearCommandBuffer();
			}
			ImGui.PopItemWidth();
		}

		private void OnCommandHistoryChange(VerticalDirection dir)
		{
			if (dir == .Up && _commandIndex > _commandStartIndex)
				_commandIndex--;
			else if (_commandIndex < _newCommandIndex)
				_commandIndex++;

			ImGui.SetKeyboardFocusHere(-1);
		}

		public void Clear()
		{
			if (_consoleType == .Log)
				ClearLog();
			else
				ClearCommands();
		}

		public void ClearLog()
		{
			for (var log in _log)
				delete log.str;
			_log.Clear();
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
