using System;
using System.Collections;
using System.IO;
using SteelEngine;
using SteelEngine.Events;
using SteelEngine.Window;
using SteelEditor.Windows;
using ImGui;
using glfw_beef;

namespace SteelEditor
{
	public class EditorLayer : Layer
	{
		private Window _window;
		private List<EditorWindow> _editorWindows = new .();

		private String _imguiIniPath = new .() ~ delete _;
		private ImGui.Style _originalStyle;

		public this(Window window) : base("EditorLayer")
		{
			_window = window;
		}

		public override void OnAttach()
		{
			if (!ImGui.CHECKVERSION())
				Log.Fatal("There is a problem with ImGui");
			
			ImGui.CreateContext();
			
			SteelPath.GetEditorUserPath(_imguiIniPath, "imgui.ini");

			var io = ref ImGui.GetIO();
			io.IniFilename = _imguiIniPath;
			io.ConfigFlags |= .DockingEnable | .ViewportsEnable;
			io.ConfigViewportsNoDecoration = false;
			
			var style = ref ImGui.GetStyle();
			style.WindowMenuButtonPosition = .None; // This disables the collapse button on windows
			style.WindowRounding = 0f;
			ImGui.StyleColorsClassic(&style);
			ImGui.PushStyleColor(.Separator, ImGui.Vec4(0, 0, 0, 0));

			_originalStyle = style;

			ImGuiImplGlfw.InitForOpenGL(_window.GetHandle, true);
			ImGuiImplOpenGL3.Init();

			Editor.RegisterWindow<NewProjectWindow>();
		}

		public override void OnDetach()
		{
			for (var editorWindow in _editorWindows)
			{
				CloseWindow(editorWindow);
				delete editorWindow;
			}

			delete _editorWindows;

			ImGuiImplOpenGL3.Shutdown();
			ImGuiImplGlfw.Shutdown();
			ImGui.DestroyContext();
		}

		public override void OnUpdate()
		{
			var io = ref ImGui.GetIO();
			var app = Editor.Instance;
			io.DisplaySize = ImGui.Vec2(app.Window.GetSize.x, app.Window.GetSize.y);
			ImGuiImplOpenGL3.NewFrame();
			ImGuiImplGlfw.NewFrame();
			ImGui.NewFrame();

			ShowMainMenuBar();
			ShowDockspace();

			// Update ImGui windows
			for (var window in _editorWindows)
			{
				if (window.IsClosed)
					continue;

				if (window.IsActive)
					window.Update();
				else
					CloseWindow(window);
			}

			// Background color
			// ImGuiImplOpenGL3.glClearColor(0.45f, 0.55f, 0.6f, 1);
			// ImGuiImplOpenGL3.glClear(ImGuiImplOpenGL3.GL_COLOR_BUFFER_BIT);

			// Rendering
			ImGui.Render();
			ImGuiImplOpenGL3.RenderDrawData(&ImGui.GetDrawData());

			if (io.ConfigFlags.HasFlag(.ViewportsEnable))
			{
				GlfwWindow* glfwContextBackup = Glfw.GetCurrentContext();
				ImGui.UpdatePlatformWindows();
				ImGui.RenderPlatformWindowsDefault();
				Glfw.MakeContextCurrent(glfwContextBackup);
			}
		}

		private void ShowDockspace()
		{
			var viewport = ImGui.GetMainViewport();
			ImGui.SetNextWindowPos(viewport.Pos);
			ImGui.SetNextWindowSize(viewport.Size);
			ImGui.SetNextWindowViewport(viewport.ID);

			ImGui.PushStyleVar(.WindowPadding, .(0, 0));
			ImGui.PushStyleVar(.WindowRounding, 0.0f);
			ImGui.PushStyleVar(.WindowBorderSize, 0.0f);
			ImGui.WindowFlags windowFlags = .MenuBar | .NoDocking | .NoTitleBar | .NoResize | .NoMove | .NoBringToFrontOnFocus | .NoNavFocus;
			ImGui.Begin("EditorMainDockspaceWindow", null, windowFlags);
			ImGui.PopStyleVar(3);

			ImGui.ID dockspaceId = ImGui.GetID("EditorMainDockspace");
			ImGui.DockSpace(dockspaceId);
			ImGui.End();
		}

		private void ShowMainMenuBar()
		{
			if (ImGui.BeginMainMenuBar())
			{
				ShowFileMenu();
				ShowEditMenu();
				ShowViewMenu();
				ShowCreateMenu();

				ImGui.EndMainMenuBar();
			}
		}

		private void ShowFileMenu()
		{
			if (ImGui.BeginMenu("File"))
			{
				if (ImGui.MenuItem("New"))
					NewProject();

				if (ImGui.MenuItem("Open"))
					OpenProject();

				if (ImGui.BeginMenu("Open Recent"))
				{
					ShowRecentProjects();
					ImGui.EndMenu();
				}

				if (ImGui.MenuItem("Save", "CTRL+S"))
					Editor.Save();

				if (ImGui.MenuItem("Close Project"))
					Editor.CloseProject();

				if (ImGui.MenuItem("Exit"))
					Application.Exit();

				ImGui.EndMenu();
			}
		}

		private void NewProject()
		{
			Editor.ShowWindow<NewProjectWindow>();
		}

		private void ShowRecentProjects()
		{
			var cache = Application.GetInstance<Editor>().[Friend]_cache;
			if (cache.RecentProjects == null)
				return;

			for (var projectPath in cache.RecentProjects)
			{
				if (ImGui.MenuItem(projectPath))
					Editor.OpenProject(projectPath);
			}
		}

		private void ShowEditMenu()
		{
			if (ImGui.BeginMenu("Edit"))
			{
				ImGui.EndMenu();
			}
		}

		private void ShowViewMenu()
		{
			if (ImGui.BeginMenu("View"))
			{
				for (var window in _editorWindows)
				{
					if (ImGui.MenuItem(window.Title.Ptr))
						RegisterWindow(window);
				}

				EditorGUI.Line();
				if (ImGui.MenuItem("Refresh"))
					Editor.Refresh();

				ImGui.EndMenu();
			}
		}

		private void ShowCreateMenu()
		{
			if (ImGui.BeginMenu("Create"))
			{
				if (ImGui.MenuItem("Entity"))
				{
					Application.Instance.CreateEntity();
					Editor.InvalidateSave();
				}

				ImGui.EndMenu();
			}
		}

		private void OpenProject()
		{
			var dialog = scope FolderBrowserDialog();
			if (dialog.ShowDialog() case .Ok(let val))
			{
				if (val == .OK)
					Editor.OpenProject(dialog.SelectedPath);
			}
			else
			{
				Log.Error("Could not show folder browser dialog");
			}
		}

		public void ShowWindow<T>() where T : EditorWindow
		{
			for (var window in _editorWindows)
			{
				if (window.GetType() == typeof(T))
				{
					RegisterWindow(window);
					return;
				}
			}

			var fullTypeName = scope String()..AppendF("{}", typeof(T));
			StringView typeName = StringView("null");
			for (var str in fullTypeName.Split('.'))
				typeName = str;

			Log.Error("{} does not exist in application", typeName);
		}

		public void RegisterWindow(StringView windowName)
		{
			for (var window in _editorWindows)
			{
				if (window.Title == windowName)
				{
					RegisterWindow(window);
					break;
				}
			}
		}

		public void RegisterWindow(EditorWindow window)
		{
			if (!window.IsActive)
			{
				window.IsActive = true;

				if (!window.[Friend]_isInitialized)
				{
					window.OnInit();
					window.[Friend]_isInitialized = true;
				}

				window.OnShow();
				window.IsClosed = false;
			}
		}

		public void RegisterWindow<T>() where T : EditorWindow
		{
			_editorWindows.Add(new T());
		}

		public void CloseWindow<T>() where T : EditorWindow
		{
			EditorWindow window = GetWindow<T>();

			if (window != null)
				CloseWindow(window);
		}

		public void CloseWindow(EditorWindow window)
		{
			window.IsActive = false;
			window.OnClose();
			window.IsClosed = true;
		}

		public T GetWindow<T>() where T : EditorWindow
		{
			for (var window in _editorWindows)
				if (typeof(T) == window.GetType())
					return (T) window;

			return null;
		}
	}
}