using System;
using System.Collections;
using System.IO;
using SteelEngine;
using SteelEngine.Window;
using SteelEngine.ECS;
using SteelEditor.Windows;
using imgui_beef;

namespace SteelEditor
{
	public class Editor : Application
	{
		private EditorLayer _editorLayer;

		private Dictionary<EntityId, String> _entityNames = new .();

		public override void OnInit()
		{
			_editorLayer = new .(Window);
			PushOverlay(_editorLayer);

			AddWindow<TestWindow>();
			AddWindow<StyleWindow>();
			AddWindow<ConsoleWindow>();
			AddWindow<InspectorWindow>();
			AddWindow<HierarchyWindow>();

			LoadConfig();
		}

		public override void OnCleanup()
		{
			SaveConfig();

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
			var editor = GetInstance<Editor>();
			if (!editor._entityNames.ContainsKey(id))
				editor._entityNames[id] = new .(name);
			else
				editor._entityNames[id].Set(name);
		}

		public static T GetWindow<T>() where T : EditorWindow
		{
			return GetInstance<Editor>()._editorLayer.GetWindow<T>();
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

		public static void SaveConfig()
		{
			Log.Trace("Saving config");

			var editor = GetInstance<Editor>();
			var config = new Dictionary<StringView, Object>();

			var openWindows = new List<StringView>();
			for (var window in editor._editorLayer.[Friend]_editorWindows)
			{
				if (window.IsActive)
					openWindows.Add(window.Title);
			}
			config.Add("Windows", openWindows);

			var style = ImGui.GetStyle();

			AddSetting(config, "Alpha", style.Alpha);
			AddSetting(config, "WindowPadding", style.WindowPadding);
			AddSetting(config, "WindowRounding", style.WindowRounding);
			AddSetting(config, "WindowBorderSize", style.WindowBorderSize);
			AddSetting(config, "WindowMinSize", style.WindowMinSize);
			AddSetting(config, "WindowTitleAlign", style.WindowTitleAlign);
			AddSetting(config, "WindowMenuButtonPosition", style.WindowMenuButtonPosition);
			AddSetting(config, "ChildRounding", style.ChildRounding);
			AddSetting(config, "ChildBorderSize", style.ChildBorderSize);
			AddSetting(config, "PopupRounding", style.PopupRounding);
			AddSetting(config, "PopupBorderSize", style.PopupBorderSize);
			AddSetting(config, "FramePadding", style.FramePadding);
			AddSetting(config, "FrameRounding", style.FrameRounding);
			AddSetting(config, "ItemSpacing", style.ItemSpacing);
			AddSetting(config, "ItemInnerSpacing", style.ItemInnerSpacing);
			AddSetting(config, "TouchExtraPadding", style.TouchExtraPadding);
			AddSetting(config, "IndentSpacing", style.IndentSpacing);
			AddSetting(config, "ColumnsMinSpacing", style.ColumnsMinSpacing);
			AddSetting(config, "ScrollbarSize", style.ScrollbarSize);
			AddSetting(config, "ScrollbarRounding", style.ScrollbarRounding);
			AddSetting(config, "GrabMinSize", style.GrabMinSize);
			AddSetting(config, "GrabRounding", style.GrabRounding);
			AddSetting(config, "TabRounding", style.TabRounding);
			AddSetting(config, "TabBorderSize", style.TabBorderSize);
			AddSetting(config, "ColorButtonPosition", style.ColorButtonPosition);
			AddSetting(config, "ButtonTextAlign", style.ButtonTextAlign);
			AddSetting(config, "SelectableTextAlign", style.SelectableTextAlign);
			AddSetting(config, "DisplayWindowPadding", style.DisplayWindowPadding);
			AddSetting(config, "DisplaySafeAreaPadding", style.DisplaySafeAreaPadding);
			AddSetting(config, "MouseCursorScale", style.MouseCursorScale);
			AddSetting(config, "AntiAliasedLines", style.AntiAliasedLines);
			AddSetting(config, "AntiAliasedFill", style.AntiAliasedFill);
			AddSetting(config, "CurveTessellationTol", style.CurveTessellationTol);
			AddSetting(config, "CircleSegmentMaxError", style.CircleSegmentMaxError);
			AddSettingType(config, "Colors", style.Colors);

			var serialized = new String();

			for (var prop in config)
			{
				if (prop.value.GetType() == typeof(ImGui.Vec2))
				{
					var vec = (ImGui.Vec2) prop.value;
					serialized.AppendF("{} = [{}, {}]\n", prop.key, vec.x, vec.y);
				}
				else if (prop.value.GetType() == typeof(List<StringView>))
				{
					var list = (List<StringView>) prop.value;
					serialized.AppendF("{} = [", prop.key);
					for (var str in list)
						serialized.AppendF("{}, ", str);
					if (serialized.EndsWith(", "))
						serialized.RemoveFromEnd(2);
					serialized.[Friend]Realloc(serialized.AllocSize);
					serialized.Append("]\n");
				}
				else
				{
					serialized.AppendF("{} = {}\n", prop.key, prop.value);
				}
			}

			for (var value in config.Values)
				delete value;
			delete config;

			var configPath = scope String();
			SteelPath.GetEditorUserFile("Config.txt", configPath, true);

			if (File.WriteAllText(configPath, serialized) case .Err)
				Log.Error("Failed to save style");

			delete serialized;

			void AddSetting<T>(Dictionary<StringView, Object> parent, StringView name, T value) where T : struct
			{
				parent[name] = new box value;
			}

			void AddSettingType(Dictionary<StringView, Object> parent, StringView name, ImGui.Vec4[(.) ImGui.Col.COUNT] vecArray)
			{
				var str = new String();
				str.Append('[');
				for (var vec in vecArray)
					str.AppendF("[{}, {}, {}, {}], ", vec.x, vec.y, vec.z, vec.w);
				str.RemoveFromEnd(2);
				str.[Friend]Realloc(str.AllocSize);
				str.Append("]");
				parent[name] = str;
			}
		}

		public static void LoadConfig()
		{
			var configPath = scope String();
			SteelPath.GetEditorUserFile("Config.txt", configPath);
			var serialized = new String();
			if (File.ReadAllText(configPath, serialized) case .Err)
			{
				delete serialized;
				return;
			}

			var config = new Dictionary<String, Object>();

			for (var line in serialized.Split('\n'))
			{
				if (line.IsWhiteSpace)
					continue;

				var lineEnumerator = line.GetEnumerator();

				var key = new String();
				for (var char in lineEnumerator)
				{
					if (char == '=')
						break;
					key.Append(char);
				}

				key.Trim();

				for (var char in lineEnumerator)
					if (!char.IsWhiteSpace)
						break;

				if (key == "Colors")
					NOP!();

				var value = ParseValue(ref lineEnumerator);
				if (value != null)
					config[key] = value;
				else
					delete key;
			}
			
			var style = ref ImGui.GetStyle();
			style.Alpha = (float) config["Alpha"];
			style.WindowPadding = GetVec2(config, "WindowPadding");
			style.WindowRounding = (float) config["WindowRounding"];
			style.WindowBorderSize = (float) config["WindowBorderSize"];
			style.WindowMinSize = GetVec2(config, "WindowMinSize");
			style.WindowTitleAlign = GetVec2(config, "WindowTitleAlign");
			style.WindowMenuButtonPosition = Enum.Parse<ImGui.Dir>((String) config["WindowMenuButtonPosition"]);
			style.ChildRounding = (float) config["ChildRounding"];
			style.ChildBorderSize = (float) config["ChildBorderSize"];
			style.PopupRounding = (float) config["PopupRounding"];
			style.PopupBorderSize = (float) config["PopupBorderSize"];
			style.FramePadding = GetVec2(config, "FramePadding");
			style.FrameRounding = (float) config["FrameRounding"];
			style.ItemSpacing = GetVec2(config, "ItemSpacing");
			style.ItemInnerSpacing = GetVec2(config, "ItemInnerSpacing");
			style.TouchExtraPadding = GetVec2(config, "TouchExtraPadding");
			style.IndentSpacing = (float) config["IndentSpacing"];
			style.ColumnsMinSpacing = (float) config["ColumnsMinSpacing"];
			style.ScrollbarSize = (float) config["ScrollbarSize"];
			style.ScrollbarRounding = (float) config["ScrollbarRounding"];
			style.GrabMinSize = (float) config["GrabMinSize"];
			style.GrabRounding = (float) config["GrabRounding"];
			style.TabRounding = (float) config["TabRounding"];
			style.TabBorderSize = (float) config["TabBorderSize"];
			style.ColorButtonPosition = Enum.Parse<ImGui.Dir>((String) config["ColorButtonPosition"]);
			style.ButtonTextAlign = GetVec2(config, "ButtonTextAlign");
			style.SelectableTextAlign = GetVec2(config, "SelectableTextAlign");
			style.DisplayWindowPadding = GetVec2(config, "DisplayWindowPadding");
			style.DisplaySafeAreaPadding = GetVec2(config, "DisplaySafeAreaPadding");
			style.MouseCursorScale = (float) config["MouseCursorScale"];
			style.AntiAliasedLines = (bool) config["AntiAliasedLines"];
			style.AntiAliasedFill = (bool) config["AntiAliasedFill"];
			style.CurveTessellationTol = (float) config["CurveTessellationTol"];
			style.CircleSegmentMaxError = (float) config["CircleSegmentMaxError"];
			GetColors(config, ref style.Colors);

			var windows = (List<Object>) config["Windows"];
			for (var window in windows)
				ShowWindow((String) window);

			for (var value in config.Values)
				DeleteObject(value);
			DeleteDictionaryAndKeys!(config);
			delete serialized;

			void DeleteObject(Object object)
			{
				if (object.GetType() == typeof(List<Object>))
				{
					for (var item in (List<Object>) object)
						DeleteObject(item);
				}
				delete object;
			}

			ImGui.Vec2 GetVec2(Dictionary<String, Object> config, String name)
			{
				var list = (List<Object>) config[name];
				if (list.Count != 2)
					return .();
				return .((float) list[0], (float) list[1]);
			}

			void GetColors(Dictionary<String, Object> config, ref ImGui.Vec4[(.) ImGui.Col.COUNT] colors)
			{
				var list = (List<Object>) config["Colors"];
				for (int i = 0; i < (.) ImGui.Col.COUNT; i++)
				{
					var subList = (List<Object>) list[i];
					var vec = ImGui.Vec4((float) subList[0], (float) subList[1], (float) subList[2], (float) subList[3]);
					colors[i] = vec;
				}
			}

			Object ParseValue(ref Span<char8>.Enumerator enumerator)
			{
				if (enumerator.Current == '[')
					return ParseArray(ref enumerator);
				else if (enumerator.Current.IsDigit)
					return ParseNumber(ref enumerator);
				else if (enumerator.Current.IsLetter)
					return ParseString(ref enumerator);
				return null;
			}

			Object ParseArray(ref Span<char8>.Enumerator enumerator)
			{
				var array = new List<Object>();
				for (var char in enumerator)
				{
					if (char == ']')
						break;
					if (char == ',' || char == ' ')
						continue;
					var value = ParseValue(ref enumerator);
					if (value != null)
						array.Add(value);
				}
				return array;
			}

			Object ParseNumber(ref Span<char8>.Enumerator enumerator)
			{
				enumerator.[Friend]mIndex--;
				var str = scope String();
				for (var char in enumerator)
				{
					if ((char == ']' || char == ',' || char.IsWhiteSpace) && char != '.')
						break;
					str.Append(char);
				}

				enumerator.[Friend]mIndex--;
				
				return new box (float) double.Parse(str).Get();
			}

			Object ParseString(ref Span<char8>.Enumerator enumerator)
			{
				enumerator.[Friend]mIndex--;
				var str = new String();
				for (var char in enumerator)
				{
					if (!char.IsLetter)
						break;
					str.Append(char);
				}
				enumerator.[Friend]mIndex--;

				bool val;
				if (str == "True")
					val = true;
				else if (str == "False")
					val = false;
				else
					return str;
				delete str;
				return new box val;
			}
		}

		public static void ResetStyle()
		{
			var style = ref ImGui.GetStyle();
			style = GetInstance<Editor>()._editorLayer.[Friend]_originalStyle;
		}
	}
}
