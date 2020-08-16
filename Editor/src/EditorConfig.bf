using System;
using System.Collections;
using imgui_beef;

namespace SteelEditor
{
	[Reflect, AlwaysInclude(AssumeInstantiated=true, IncludeAllMethods=true)]
	public class EditorConfig
	{
		public List<StringView> Windows = new .() ~ delete _;
		public ImGui.Style Style;
	}
}
