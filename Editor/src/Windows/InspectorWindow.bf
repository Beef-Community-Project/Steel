using System;
using System.Collections;
using SteelEngine.ECS;
using SteelEngine.ECS.Components;
using SteelEngine;
using System.Reflection;
using ImGui;
using System.IO;

namespace SteelEditor.Windows
{
	class InspectorWindow : EditorWindow
	{
		public override StringView Title => "Inspector";

		private Entity _entity = null;
		private String _entityName = new .() ~ delete _;
		private bool _showAddComponentPopup = false;

		private bool _isFileView = false;
		private String _filePath = null ~ if (_ != null) delete _;
		private String _fileBuffer = null ~ if (_ != null) delete _;

		public static void SetCurrentEntity(Entity entity)
		{
			var inspector = Editor.GetWindow<InspectorWindow>();
			inspector._entity = entity;
			if (inspector._isFileView)
				inspector.ClearFileView();
		}

		public static void ViewFile(StringView filePath)
		{
			var inspector = Editor.GetWindow<InspectorWindow>();
			inspector._isFileView = true;

			if (inspector._fileBuffer == null)
				inspector._fileBuffer = new .();

			if (!inspector._fileBuffer.IsEmpty)
				inspector._fileBuffer.Clear();

			if (inspector._filePath == null)
				inspector._filePath = new .(filePath);
			else
				inspector._filePath.Set(filePath);

			File.ReadAllText(filePath, inspector._fileBuffer);
		}

		private void ClearFileView()
		{
			_isFileView = false;
			_fileBuffer.Clear();
		}

		public override void OnRender()
		{
			if (_isFileView)
			{
				ShowFileView();
				return;
			}

			if (_entity == null)
				return;

			_entity.IsEnabled = EditorGUI.Checkbox("##EntityEnabled", _entity.IsEnabled);

			_entityName.Clear();
			Editor.GetEntityName(_entity.Id, _entityName);

			EditorGUI.SameLine();
			EditorGUI.ItemWidth(-25);
			if (EditorGUI.Input("##EntityName", _entityName).OnChange)
				Editor.SetEntityName(_entity.Id, _entityName);

			EditorGUI.AlignFromRight(25);
			if (EditorGUI.Button("X"))
			{
				Application.Instance.[Friend]RemoveEntity(_entity);
				SetCurrentEntity(null);
				Editor.InvalidateSave();
				return;
			}	

			EditorGUI.Line();
			EditorGUI.AddColumns();

			var componentsToRender = scope List<BaseComponent>();

			for (var component in Editor.Instance.[Friend]_components.Values)
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
				var isOpen = EditorGUI.BeginCollapsableHeader(componentName);

				EditorGUI.AlignFromRight(20);
				if (EditorGUI.Selectable("X"))
				{
					_entity.RemoveComponent(component);
					continue;
				}

				if (isOpen)
				{
					RenderObject(component);
					EditorGUI.EndCollapsableHeader();
				}
			}

			EditorGUI.RemoveColumns();
			EditorGUI.NewLine();
			EditorGUI.AlignMiddle(130);
			if (EditorGUI.Button("Add Component", .(130, 20)))
				_showAddComponentPopup = true;

			if (_showAddComponentPopup)
				ShowAddComponentPopup();
		}

		private void ShowFileView()
		{
			EditorGUI.Text(_filePath);
			EditorGUI.InputMultiline("##FileView", _fileBuffer, 1024, true);
		}

		private void ShowAddComponentPopup()
		{
			Type componentType = null;

			if (EditorGUI.BeginWindow("Add Component", ref _showAddComponentPopup))
			{
				for (var type in Type.Types)
				{
					if (type.IsSubtypeOf(typeof(BaseComponent)))
					{
						var typeName = scope String();
						type.GetShortName(typeName);
						if (typeName == "BaseComponent" || typeName == "BehaviourComponent")
							continue;

						if (EditorGUI.Selectable(typeName))
						{
							componentType = type;
							_showAddComponentPopup = false;
							break;
						}
					}
				}

				EditorGUI.EndWindow();
			}

			if (componentType != null)
			{
				var createResult = componentType.CreateObject();
				if (createResult case .Err)
				{
					var typeName = scope String();
					componentType.GetName(typeName);
					Log.Error("Failed create component ({})", typeName);
					return;
				}

				_entity.AddComponent((BaseComponent) createResult.Get());
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
				if (!type.IsSubtypeOf(typeof(BaseComponent)))
					RenderValue(name, object);
				return;
			}
			
			RenderFields(fields, object);
		}

		private void RenderValue(StringView name, Object object)
		{
			if (object.GetType().IsSubtypeOf(typeof(Entity)))
				return;

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
						if (!EditorGUI.BeginCollapsableHeader(field.GetName()))
							break;

						RenderObject(variant.Get<Object>(), field.FieldType, field.GetName());
						EditorGUI.EndCollapsableHeader();
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
