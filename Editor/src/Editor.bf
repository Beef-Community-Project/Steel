using System;
using System.Collections;
using System.IO;
using SteelEngine;
using SteelEngine.Window;
using SteelEngine.ECS;
using SteelEditor.Windows;
using JetFistGames.Toml;
using imgui_beef;

namespace SteelEditor
{
	public class Editor : Application
	{
		private EditorLayer _editorLayer;
		private EditorConfig _config = new .();

		private Dictionary<EntityId, String> _entityNames = new .();

		public override void OnInit()
		{
			_editorLayer = new .(Window);
			PushOverlay(_editorLayer);

			AddWindow<TestWindow>();
			AddWindow<StyleWindow>();
			AddWindow<ConsoleWindow>();
			AddWindow<InspectorWindow>();
			

			if (LoadConfig() case .Ok)
			{
				var style = ref ImGui.GetStyle();
				style = _config.Style;

				for (var window in _config.Windows)
					ShowWindow(window);
			}
			
			ShowWindow<InspectorWindow>();
		}

		public override void OnCleanup()
		{
			SaveConfig();

			delete _config;

			for (var value in _entityNames.Values)
				delete value;
			delete _entityNames;
		}

		public static void GetEntityName(EntityId id, String buffer)
		{
			var editor = GetInstance<Editor>();
			if (!editor._entityNames.ContainsKey(id))
				SetEntityName(id, "Entity");

			buffer.Append(editor._entityNames[id]);
		}

		public static void SetEntityName(EntityId id, StringView name)
		{
			GetInstance<Editor>()._entityNames[id] = new .(name);
		}

		public static void ShowWindow<T>() where T : EditorWindow
		{
			GetInstance<Editor>()._editorLayer.ShowWindow<T>();
		}

		public static void ShowWindow(StringView windowName)
		{
			GetInstance<Editor>()._editorLayer.ShowWindow(windowName);
		}

		public static void ShowWindow(EditorWindow window)
		{
			GetInstance<Editor>()._editorLayer.ShowWindow(window);
		}

		public static void AddWindow<T>() where T : EditorWindow
		{
			GetInstance<Editor>()._editorLayer.AddWindow<T>();
		}

		public static void CloseWindow(EditorWindow window)
		{
			GetInstance<Editor>()._editorLayer.CloseWindow(window);
		}

		public static void UpdateConfig()
		{
			let editor = GetInstance<Editor>();

			var editorWindows = editor._editorLayer.[Friend]_editorWindows;
			editorWindows.Clear();

			for (var window in editorWindows)
				editor._config.Windows.Add(window.Title);

			editor._config.Style = ImGui.GetStyle();
		}

		public static void SaveConfig()
		{
			Log.Trace("Saving config");

			/*let serializeResult = JSONSerializer.Serialize<String>(GetInstance<Editor>()._config);

			if (serializeResult case .Err)
			{
				Log.Error("Could not serialize config");
				return;
			}

			var serialized = serializeResult.Get();

			var configPath = scope String();
			SteelPath.GetEditorUserFile("Config.json", configPath);

			if (File.WriteAllText(configPath, serialized) case .Err)
				Log.Error("Failed to save style");

			delete serialized;*/

			TomlTableNode config = new .();

			 // Style

			var style = ImGui.GetStyle();
			TomlTableNode styleTable = new .();
			config.AddChild("Style", styleTable);

			AddSetting(styleTable, "Alpha", style.Alpha);
			AddSetting(styleTable, "WindowPadding", style.WindowPadding);
			AddSetting(styleTable, "WindowRounding", style.WindowRounding);
			AddSetting(styleTable, "WindowBorderSize", style.WindowBorderSize);
			AddSetting(styleTable, "WindowMinSize", style.WindowMinSize);
			AddSetting(styleTable, "WindowTitleAlign", style.WindowTitleAlign);
			AddSetting(styleTable, "WindowMenuButtonPosition", style.WindowMenuButtonPosition);
			AddSetting(styleTable, "ChildRounding", style.ChildRounding);
			AddSetting(styleTable, "ChildBorderSize", style.ChildBorderSize);
			AddSetting(styleTable, "PopupRounding", style.PopupRounding);
			AddSetting(styleTable, "PopupBorderSize", style.PopupBorderSize);
			AddSetting(styleTable, "FramePadding", style.FramePadding);
			AddSetting(styleTable, "FrameRounding", style.FrameRounding);
			AddSetting(styleTable, "ItemSpacing", style.ItemSpacing);
			AddSetting(styleTable, "ItemInnerSpacing", style.ItemInnerSpacing);
			AddSetting(styleTable, "TouchExtraPadding", style.TouchExtraPadding);
			AddSetting(styleTable, "IndentSpacing", style.IndentSpacing);
			AddSetting(styleTable, "ColumnsMinSpacing", style.ColumnsMinSpacing);
			AddSetting(styleTable, "ScrollbarSize", style.ScrollbarSize);
			AddSetting(styleTable, "ScrollbarRounding", style.ScrollbarRounding);
			AddSetting(styleTable, "GrabMinSize", style.GrabMinSize);
			AddSetting(styleTable, "GrabRounding", style.GrabRounding);
			AddSetting(styleTable, "TabRounding", style.TabRounding);
			AddSetting(styleTable, "TabBorderSize", style.TabBorderSize);
			AddSetting(styleTable, "ColorButtonPosition", style.ColorButtonPosition);
			AddSetting(styleTable, "ButtonTextAlign", style.ButtonTextAlign);
			AddSetting(styleTable, "SelectableTextAlign", style.SelectableTextAlign);
			AddSetting(styleTable, "DisplayWindowPadding", style.DisplayWindowPadding);
			AddSetting(styleTable, "DisplaySafeAreaPadding", style.DisplaySafeAreaPadding);
			AddSetting(styleTable, "MouseCursorScale", style.MouseCursorScale);
			AddSetting(styleTable, "AntiAliasedLines", style.AntiAliasedLines);
			AddSetting(styleTable, "AntiAliasedFill", style.AntiAliasedFill);
			AddSetting(styleTable, "CurveTessellationTol", style.CurveTessellationTol);
			AddSetting(styleTable, "CircleSegmentMaxError", style.CircleSegmentMaxError);
			AddSetting(styleTable, "Colors", style.Colors);

			// Windows

			var windowsArray = new TomlArrayNode();
			config.AddChild("Windows", windowsArray);

			for (var window in GetInstance<Editor>()._editorLayer.[Friend]_editorWindows)
			{
				if (window.IsActive)
					windowsArray.AddChild(new TomlValueNode(.String, window.Title));
			}

			var configPath = scope String();
			SteelPath.GetEditorUserFile("Config.toml", configPath);

			var serialized = scope String();
			TomlSerializer.Write(config, serialized);

			if (File.WriteAllText(configPath, serialized) case .Err)
				Log.Error("Failed to save style");

			delete config;

			void AddSetting(TomlTableNode parent, StringView name, float value)
			{
				parent.AddChild<TomlValueNode>(name).SetFloat(value);
			}

			void AddSetting(TomlTableNode parent, StringView name, bool value)
			{
				parent.AddChild<TomlValueNode>(name).SetBool(value);
			}

			void AddSetting(TomlTableNode parent, StringView name, ImGui.Vec2 value)
			{
				var array = parent.AddChild<TomlArrayNode>(name);
				array.AddChild<TomlValueNode>().SetFloat(value.x);
				array.AddChild<TomlValueNode>().SetFloat(value.y);
			}

			void AddSetting(TomlTableNode parent, StringView name, ImGui.Dir value)
			{
				parent.AddChild<TomlValueNode>(name).SetInt((int) value);
			}

			void AddSetting(TomlTableNode parent, StringView name, ImGui.Vec4[(.) ImGui.Col.COUNT] value)
			{
				var array = parent.AddChild<TomlArrayNode>(name);
				for (var vec in value)
				{
					var subArray = array.AddChild<TomlArrayNode>();
					subArray.AddChild<TomlValueNode>().SetFloat(vec.w);
					subArray.AddChild<TomlValueNode>().SetFloat(vec.x);
					subArray.AddChild<TomlValueNode>().SetFloat(vec.y);
					subArray.AddChild<TomlValueNode>().SetFloat(vec.z);
				}	
			}
		}

		public static Result<void> LoadConfig()
		{
			// Deserializing the file causes a Stack overflow. TODO(RogueMacro): Fix BeefToml and remove this return statement
			return .Err;

			var configPath = scope String();
			SteelPath.GetEditorUserFile("Config.toml", configPath);

			if (!File.Exists(configPath))
				return .Err;

			if (TomlSerializer.ReadFile(configPath, GetInstance<Editor>()._config) case .Err(let err))
			{
				Log.Error("Could not load config: {}", err);
				err.Dispose();
				return .Err;
			}

			return .Ok;
		}
	}
}
