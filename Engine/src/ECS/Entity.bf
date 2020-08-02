using System;
using System.Collections;
using SteelEngine.ECS.Components;
using SteelEngine.ECS.Systems;

namespace SteelEngine.ECS
{
	public class Entity
	{
		public this(Application app)
		{
			App = app;
			Id = GetNextId();
			IsEnabled = true;

			Entity.EntityStore[Id] = this;
		}

		static this()
		{
			EntityStore = new Dictionary<uint64, Entity>();
		}

		public Application App { get; private set; }

		public static Dictionary<uint64, Entity> EntityStore { get; private set; }

		/// <summary>
		/// Unique identifier for the Entity.
		/// </summary>
		public uint64 Id { get; private set; }

		/// <summary>
		/// Whether or not the Entity and all child Components should be drawn or updated.
		/// </summary>
		public bool IsEnabled { get; set; }

		#region Member Methods
		/// <summary>
		/// Adds a <see cref="SteelEngine.ECS.BaseComponent"/> to the relevant <see cref="SteelEngine.ECS.Systems.System"/>. <see cref="AddComponent(Component)"/> will also remove the <see cref="SteelEngine.ECS.BaseComponent"/> from any Entity and <see cref="SteelEngine.ECS.Systems.System"/> it was attached to before.
		/// </summary>
		/// <param name="component"><see cref="SteelEngine.ECS.Components.BaseComponent"/> to add.</param>
		public bool AddComponent(BaseComponent component)
		{
			let parent = component.Parent;
			if (parent != null && (parent.Id == Id || !parent.RemoveComponent(component)))
			{
				return false;
			}
			component.Parent = this;
			return App.[Friend]AddComponent(component);
		}

		/// <summary>
		/// Removes an individual <see cref="SteelEngine.ECS.BaseComponent"/>.
		/// </summary>
		/// <param name="component"><see cref="SteelEngine.ECS.BaseComponent"/> to remove.</param>
		/// <returns>Whether or not the <see cref="SteelEngine.ECS.BaseComponent"/> was removed. Will return false if the <see cref="SteelEngine.ECS.BaseComponent"/> is not registered to this Entity.</returns>
		public bool RemoveComponent(BaseComponent component)
		{
			let parent = component?.Parent;
			if (parent == null || parent.Id != Id)
			{
				return false;
			}
			return App.[Friend]RemoveComponent(component);
		}

		private static uint64 _nextId = 0;

		private static uint64 GetNextId()
		{
			return _nextId++;
		}

		public ~this()
		{
			App.[Friend]RemoveEntity(this);
			Entity.EntityStore.Remove(Id);
		}

		static ~this()
		{
			delete EntityStore;
		}
	}
}
