using System;
using System.Collections;
using System.IO;
using SteelEngine;
using SteelEngine.Window;
using SteelEngine.ECS;
using SteelEditor.Windows;
using SteelEditor.Serialization;
using ImGui;
using JSON_Beef.Serialization;

namespace SteelEditor
{
	public class Editor : Application
	{
		private EditorLayer _editorLayer;

		private Dictionary<EntityId, String> _entityNames = new .();
		private EditorCache _cache = new .(true) ~ delete _;
		private bool _wantsSave = false;

		public EditorProject CurrentProject = EditorProject.UntitledProject() ~ delete _;

		private String _currentTheme = new .() ~ delete _;

		public override void OnInit()
		{
			_editorLayer = new .(Window);
			PushOverlay(_editorLayer);

			RegisterWindow<TestWindow>();
			RegisterWindow<StyleWindow>();
			RegisterWindow<ConsoleWindow>();
			RegisterWindow<InspectorWindow>();
			RegisterWindow<HierarchyWindow>();
			RegisterWindow<ContentWindow>();
			RegisterWindow<PropertiesWindow>();

			LoadConfig();
			LoadCache();

			UpdateTitle();

			Log.Trace("Editor Resource Path: {}", SteelPath.EngineInstallationPath);
		}

		public override void OnCleanup()
		{
			SaveConfig();
			SaveCache();

			for (var value in _entityNames.Values)
				delete value;
			delete _entityNames;
		}

		public static void InvalidateSave()
		{
			GetInstance<Editor>()._wantsSave = true;
			UpdateTitle();
		}

		public static void SetTheme(StringView themeName)
		{
			String fileName = scope .(themeName)..Append(".txt");
			String _themePath = scope .();
			SteelPath.GetEditorResourcePath(_themePath, "Themes", fileName);

			String theme = new .();
			defer delete theme;

			File.ReadAllText(_themePath, theme);
			LoadStyle(theme);
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

		public static void Refresh()
		{
			for (var window in GetInstance<Editor>()._editorLayer.[Friend]_editorWindows)
				window.OnShow();
		}

		public static void OpenProject(StringView path)
		{
			GameConsole.Instance.Clear();

			var filePath = scope String();
			Path.InternalCombine(filePath, scope String(path), "SteelProj.json");

			if (!File.Exists(filePath))
			{
				Log.Error("Could not open project ({}): Not a Steel project", path);
				return;
			}

			var json = new String();
			defer delete json;

			if (File.ReadAllText(filePath, json) case .Err(let err))
			{
				Log.Error("Could not open project ({}): {}", path, err);
				return;
			}

			var editor = GetInstance<Editor>();
			delete editor.CurrentProject;
			editor.CurrentProject = new .();

			for (var entity in Entity.EntityStore.Values)
				delete entity;
			Entity.EntityStore.Clear();

			if (JSONDeserializer.Deserialize<EditorProject>(json, editor.CurrentProject) case .Err(let err))
			{
				Log.Error("Could not open project ({}): {}", path, err);
				return;
			}

			for (var serializableEntity in editor.CurrentProject.Entities)
				serializableEntity.MakeEntity();

			editor.CurrentProject.Path = new .(path);
			UpdateTitle();

			editor._cache.AddRecentProject(path);

			InspectorWindow.SetCurrentEntity(null);
			SteelPath.SetContentDirectory();
			Refresh();
		}

		public static void CloseProject()
		{
			Log.Info("Closing project");

			var editor = GetInstance<Editor>();
			delete editor.CurrentProject;
			editor.CurrentProject = EditorProject.UntitledProject();
			UpdateTitle();
		}

		public static void UpdateTitle()
		{
			var editor = GetInstance<Editor>();
			var title = scope String();

			if (editor.CurrentProject.Path.IsEmpty)
				title.AppendF("Steel Editor - {}", editor.CurrentProject.Name);
			else
				title.AppendF("Steel Editor - {}", editor.CurrentProject.Path);

			if (editor._wantsSave)
				title.Append('*');

			editor.Window.SetTitle(title);
		}

		public static void Save()
		{
			Log.Trace("Saving project");

			var editor = GetInstance<Editor>();

			editor.CurrentProject.Entities.Clear();
			for (var entity in Entity.EntityStore.Values)
			{
				var entityName = scope String();
				GetEntityName(entity.Id, entityName);
				editor.CurrentProject.Entities.Add(new .(entityName, entity));
			}

			var result = JSONSerializer.Serialize<String>(editor.CurrentProject);
			if (result case .Err)
			{
				Log.Error("Could not save project: Serialization error");
				return;
			}

			var json = result.Get();
			defer delete json;

			var projectFilePath = scope String();
			Path.InternalCombine(projectFilePath, editor.CurrentProject.Path, "SteelProj.json");

			if (File.WriteAllText(projectFilePath, json) case .Err)
				Log.Error("Could not save cache: File error");

			editor._wantsSave = false;
			UpdateTitle();

			SaveCache();
		}

		public static void SaveCache()
		{
			Log.Trace("Saving cache");

			var editor = GetInstance<Editor>();
			editor._cache.Update(editor);
			editor._cache.MakeSerializable();

			var result = JSONSerializer.Serialize<String>(editor._cache);
			if (result case .Err)
			{
				Log.Error("Could not save cache: Serialization error");
				return;
			}

			var json = result.Get();
			defer delete json;

			var cachePath = scope String();
			SteelPath.GetEditorUserPath(cachePath, "Cache.json");

			if (File.WriteAllText(cachePath, json) case .Err)
				Log.Error("Could not save cache: File error");
		}

		private static void LoadCache()
		{
			Log.Trace("Loading cache");

			var cachePath = scope String();
			SteelPath.GetEditorUserPath(cachePath, "Cache.json");

			var json = new String();
			defer delete json;

			if (File.ReadAllText(cachePath, json) case .Err(let err))
			{
				Log.Error("Could not load cache: {}", err);
				return;
			}

			var editor = GetInstance<Editor>();

			if (editor._cache != null)
				delete editor._cache;
			editor._cache = new .();

			if (JSONDeserializer.Deserialize<EditorCache>(json, editor._cache) case .Err(let err))
			{
				Log.Error("Could not load cache: {}", err);
				delete editor._cache;
				editor._cache = new .(true);
			}
		}

		public static T GetWindow<T>() where T : EditorWindow
		{
			return GetInstance<Editor>()._editorLayer.GetWindow<T>();
		}

		public static void ShowWindow<T>() where T : EditorWindow
		{
			GetInstance<Editor>()._editorLayer.ShowWindow<T>();
		}

		public static void RegisterWindow(StringView windowName)
		{
			GetInstance<Editor>()._editorLayer.RegisterWindow(windowName);
		}

		public static void RegisterWindow(EditorWindow window)
		{
			GetInstance<Editor>()._editorLayer.RegisterWindow(window);
		}

		public static void RegisterWindow<T>() where T : EditorWindow
		{
			GetInstance<Editor>()._editorLayer.RegisterWindow<T>();
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
			SteelPath.GetEditorUserPath(configPath, "Config.txt");

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
			SteelPath.GetEditorUserPath(configPath, "Config.txt");
			var serialized = new String();
			defer delete serialized;
			if (File.ReadAllText(configPath, serialized) case .Err)
				return;

			ParseConfig(serialized, var config);
			LoadStyle(config);

			var windows = (List<Object>) config["Windows"];
			for (var window in windows)
				RegisterWindow((String) window);

			DeleteConfig!(config);
		}

		public static void LoadStyle(StringView str)
		{
			ParseConfig(str, var config);
			LoadStyle(config);
			DeleteConfig!(config);
		}

		private static void LoadStyle(Dictionary<String, Object> config)
		{
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
		}

		private static void ParseConfig(StringView str, out Dictionary<String, Object> config)
		{
			config = new Dictionary<String, Object>();

			for (var line in str.Split('\n'))
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

				var value = ParseValue(ref lineEnumerator);
				if (value != null)
					config[key] = value;
				else
					delete key;
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

		private static mixin DeleteConfig(Dictionary<String, Object> config)
		{
			for (var value in config.Values)
				DeleteObject(value);
			DeleteDictionaryAndKeys!(config);

			void DeleteObject(Object object)
			{
				if (object.GetType() == typeof(List<Object>))
				{
					for (var item in (List<Object>) object)
						DeleteObject(item);
				}
				delete object;
			}
		}

		public static void ResetStyle()
		{
			var style = ref ImGui.GetStyle();
			style = GetInstance<Editor>()._editorLayer.[Friend]_originalStyle;
		}
	}
}
