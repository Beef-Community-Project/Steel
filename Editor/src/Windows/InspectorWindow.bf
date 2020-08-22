using System;
using System.Collections;
using SteelEngine.ECS;
using SteelEngine.ECS.Components;
using SteelEngine;
using System.Reflection;
using imgui_beef;

namespace SteelEditor.Windows
{
	class InspectorWindow : EditorWindow
	{
		public override StringView Title => "Inspector";

		private Entity _entity = new Entity();
		private String _entityName = new .() ~ delete _;

		public override void OnShow()
		{
			_entity.AddComponent(new TransformComponent());
		}

		public override void OnRender()
		{
			if (_entity == null)
				return;

			_entity.IsEnabled = EditorGUI.Checkbox("##EntityEnabled", _entity.IsEnabled);

			Editor.GetEntityName(_entity.Id, _entityName);
			EditorGUI.SameLine();
			EditorGUI.Input("##EntityName", _entityName);

			EditorGUI.Line();

			var componentsToRender = scope List<BaseComponent>();

			for (var component in Application.Instance.[Friend]_components.Values)
				if (component.Parent == _entity)
					componentsToRender.Add(component);

			for (var component in componentsToRender)
			{
				var componentName = scope String();
				component.GetType().GetShortName(componentName);
				if (componentName.EndsWith("Component"))
				{
					componentName.RemoveFromEnd(9);
					componentName.[Friend]Realloc(componentName.AllocSize);
				}

				EditorGUI.ItemID(scope String()..AppendF("{}", component));
				if (EditorGUI.BeginTree(componentName))
				{
					RenderObject(component);
					RenderObject<BaseComponent>(component);
					EditorGUI.EndTree();
				}
			}
		}

		private void RenderObject<T>(Object object, StringView name = "") => RenderObject(object, typeof(T), name);
		private void RenderObject(Object object, StringView name = "") => RenderObject(object, object.GetType(), name);

		private void RenderObject(Object object, Type type, StringView preferredName = "")
		{
			var name = scope String(preferredName);
			if (preferredName == "")
				type.GetName(name);

			var fields = scope List<FieldInfo>(type.GetFields(.Instance | .Public));
			if (fields.IsEmpty)
			{
				RenderValue(name, object);
				return;
			}
			
			//ImGui.Columns(2);
			RenderFields(fields, object);
		}

		private void RenderValue(StringView name, Object object)
		{
			EditorGUI.LabelText(name, "{}", object);
		}

		private void RenderFields(List<FieldInfo> fields, Object object)
		{
			ImGui.Columns(2);

			for (var field in fields)
			{
				if (field.FieldType.IsInteger)
				{
					//RenderInt(field, component);
					continue;
				}
				
				switch (field.FieldType)
				{
				case typeof(Vector3):
					RenderField<Vector3>(=> EditorGUI.Vector3, field, object);
					break;
				case typeof(Vector2):
					RenderField<Vector2>(=> EditorGUI.Vector2, field, object);
					break;
				case typeof(bool):
					RenderField<bool>(=> EditorGUI.Checkbox, field, object);
					break;
				case typeof(Entity):
					var variant = field.GetValue(object).Get();
					RenderValue(field.GetName(), variant.Get<Entity>());
					variant.Dispose();
					break;
				default:
					var variant = field.GetValue(object).Get();
					if (variant.IsObject)
					{
						if (!EditorGUI.BeginTree(field.GetName()))
							continue;

						RenderObject(variant.Get<Object>(), field.FieldType, field.GetName());
						EditorGUI.EndTree();
					}
					variant.Dispose();
				}
			}
		}

		private void RenderField<T>(function T(StringView label, T value) callback, FieldInfo field, Object component)
		{
			var variant = field.GetValue(component).Get();
			field.SetValue(component, callback(field.GetName(), variant.Get<T>()));
			variant.Dispose();
		}

		private void RenderInt(FieldInfo field, BaseComponent component)
		{
			var fieldName = field.GetName();
			Variant variant = ?;

			switch (field.FieldType)
			{
			case typeof(int):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (int) EditorGUI.Int(fieldName, variant.Get<int>()));
			case typeof(int8):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (int8) EditorGUI.Int(fieldName, variant.Get<int8>()));
			case typeof(int16):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (int16) EditorGUI.Int(fieldName, variant.Get<int16>()));
			case typeof(int32):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (int32) EditorGUI.Int(fieldName, variant.Get<int32>()));
			case typeof(int64):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (int64) EditorGUI.Int(fieldName, variant.Get<int64>()));

			case typeof(uint):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (uint) EditorGUI.Int(fieldName, (int) variant.Get<uint>()));
			case typeof(uint8):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (uint8) EditorGUI.Int(fieldName, variant.Get<uint8>()));
			case typeof(uint16):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (uint16) EditorGUI.Int(fieldName, variant.Get<uint16>()));
			case typeof(uint32):
				variant = field.GetValue(component).Get();
				field.SetValue(component, (uint32) EditorGUI.Int(fieldName, variant.Get<uint32>()));
			case typeof(uint64):
				variant = field.GetValueReference(component).Get();
				field.SetValue(component, (uint64) EditorGUI.Int(fieldName, (int) variant.Get<uint64>()));
			default:
				return;
			}

			variant.Dispose();
		}
	}
}
