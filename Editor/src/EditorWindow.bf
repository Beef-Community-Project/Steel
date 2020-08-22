using System;
using SteelEngine;
using imgui_beef;

namespace SteelEditor
{
	public abstract class EditorWindow
	{
		// Pointer to fixed memory i.e. public override StringView Title => "MyEditorWindow";
		public abstract StringView Title { get; }

		public bool IsActive = false;
		public bool IsClosed = true;

		private bool _isInitialized = false;

		public void Update()
		{
			if (!IsActive)
				return;

			if (EditorGUI.BeginWindow(Title, ref IsActive))
			{
				OnRender();
				EditorGUI.EndWindow();
			}
		}

		public virtual void OnInit() {}
		public virtual void OnShow() {}
		public virtual void OnRender() {}
		public virtual void OnClose() {}
	}
}
