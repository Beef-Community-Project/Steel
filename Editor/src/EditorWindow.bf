using System;
using imgui_beef;

namespace SteelEditor
{

	public abstract class EditorWindow
	{
		// Pointer to fixed memory i.e. public override StringView Title => "MyEditorWindow";
		public abstract StringView Title { get; }

		public bool IsActive = true;

		public void Update()
		{
			if (!IsActive)
				return;

			// ImGui.ShowDemoWindow();

			if (ImGui.Begin(Title.Ptr, &IsActive))
				OnRender();
			
			ImGui.End();
		}

		public virtual void OnInit() {}
		public virtual void OnRender() {}
		public virtual void OnClose() {}
	}
}
