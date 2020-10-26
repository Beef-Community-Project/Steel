using System;
using System.Collections;
using JSON_Beef.Attributes;
using ImGui;

namespace SteelEditor.Serialization
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class EditorCache
	{
		[IgnoreSerialize]
		private int MaxRecentProjects = 5;

		public List<String> RecentProjects = null;
		
		[IgnoreSerialize] // Temporary until structs can be serialized
		public ImGui.Style Style;

		public this(bool initDefault = false)
		{
			if (!initDefault)
				return;

			RecentProjects = new .();
		}

		public ~this()
		{
			if (RecentProjects != null)
				DeleteContainerAndItems!(RecentProjects);
		}

		public void Update(Editor editor)
		{
			Style = ImGui.GetStyle();
		}

		public void AddRecentProject(StringView path)
		{
			if (RecentProjects.Count >= MaxRecentProjects)
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
				path.MakeSerializable();
		}
	}
}
