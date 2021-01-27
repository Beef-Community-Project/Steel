using System;
using System.Collections;
using JSON_Beef.Attributes;
using ImGui;
using SteelEngine;

namespace SteelEditor.Serialization
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class EditorCache
	{
		[IgnoreSerialize]
		private const int MAX_RECENT_PROJECTS = 5;

		public List<String> RecentProjects = null;
		public List<String> Windows = null;
		
		[IgnoreSerialize] // Temporary until structs can be serialized
		public ImGui.Style Style;

		public this(bool init = false)
		{
			if (!init)
				return;

			RecentProjects = new .();
			Windows = new .();
		}

		public ~this()
		{
			if (RecentProjects != null)
				DeleteContainerAndItems!(RecentProjects);

			if (Windows != null)
				DeleteContainerAndItems!(Windows);
		}

		public void Update()
		{
			DeleteAndClearItems!(Windows);

			for (var window in Application.GetInstance<Editor>().[Friend]_editorLayer.[Friend]_editorWindows)
			{
				if (window.IsActive)
					Windows.Add(new String(window.Title));
			}

			Style = ImGui.GetStyle();
		}

		public void AddRecentProject(StringView path)
		{

			if (Windows == null)
				Windows = new .();
			if (RecentProjects.Count >= MAX_RECENT_PROJECTS)
				RecentProjects.PopFront();

			var pathString = new String(path);
			if (RecentProjects.Contains(pathString))
				delete RecentProjects.GetAndRemove(pathString).Get();

			RecentProjects.Add(pathString);
		}

		public void MakeSerializable()
		{
			if (RecentProjects == null)
				RecentProjects = new .();

			for (var path in RecentProjects)
				path.MakePath();
		}
	}
}
