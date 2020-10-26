using System;
using SteelEngine;
using SteelEngine.ECS;
using ImGui;

namespace SteelEditor.Windows
{
	public class HierarchyWindow : EditorWindow
	{
		public override StringView Title => "Hierarchy";

		private Entity _currentEntity = null;

		public override void OnRender()
		{
			for (var entity in Entity.EntityStore.Values)
			{
				var entityName = scope String();
				Editor.GetEntityName(entity.Id, entityName);

				if (!entity.IsEnabled)
					EditorGUI.TextColor(Color.Gray);

				EditorGUI.ItemID(scope String()..AppendF("{}", entity.Id));
				if (EditorGUI.Selectable(entityName, _currentEntity != null && _currentEntity == entity))
				{
					InspectorWindow.SetCurrentEntity(entity);
					_currentEntity = entity;
				}

				if (ImGui.BeginPopupContextItem())
				{
					ShowEntityPopupMenu();
					ImGui.EndPopup();
				}
			}

			if (ImGui.BeginPopupContextWindow())
			{
				ShowHierarchyPopupMenu();
				ImGui.EndPopup();
			}
		}

		private void ShowHierarchyPopupMenu()
		{
			if (ImGui.BeginMenu("Create"))
			{
				if (ImGui.MenuItem("Empty Entity"))
					Application.Instance.CreateEntity();

				ImGui.EndMenu();
			}
		}

		private void ShowEntityPopupMenu()
		{
			if (ImGui.MenuItem("Delete"))
			{
				InspectorWindow.SetCurrentEntity(null);
				delete _currentEntity;
			}
		}
	}
}
