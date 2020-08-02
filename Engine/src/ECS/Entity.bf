using System;
using System.Collections;
using SteelEngine.ECS.Components;
using SteelEngine.ECS.Systems;

namespace SteelEngine.ECS
{
	/// <summary>
	/// Represents a collection of <see cref="SteelEngine.ECS.BaseComponent"/> objects tracked by the relevant <see cref="SteelEngine.ECS.Systems.System"/> objects.
	/// </summary>
	public class Entity
	{
	    /// <param name="game">Reference to current <see cref="SteelEngine.Application"/> instance.</param>
	    public this(Application app)
	    {
	        Id = GetNextId();
	        IsEnabled = true;
			App = app;
	    }

		static this()
		{
			EntityStore = new Dictionary<uint64, Entity>();
		}

		public static Dictionary<uint64, Entity> EntityStore { get; private set; }

		public Application App { get; private set; }

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
			if (component.Parent != null)
			{
				if (component.Parent.Id == this.Id)
				{
					return false;
				}
				//Game.RemoveComponent(component);
			}
			component.Parent = this;
	        //return Game.AddComponent(component);
			return false;
	    }

	    /// <summary>
	    /// Removes an individual <see cref="SteelEngine.ECS.BaseComponent"/> from this Entity's <see cref="Components"/>.
	    /// </summary>
	    /// <param name="component"><see cref="SteelEngine.ECS.BaseComponent"/> to remove.</param>
	    /// <returns>Whether or not the <see cref="SteelEngine.ECS.BaseComponent"/> was removed from this Entity's <see cref="Components"/>. Will return false if the <see cref="SteelEngine.ECS.BaseComponent"/> is not present in <see cref="Components"/>.</returns>
	    public bool RemoveComponent(BaseComponent component)
	    {
			if (component.Parent == null || component.Parent.Id != this.Id)
			{
				return false;
			}
	        //return Game.RemoveComponent(component);
			return false;
	    }

		private static uint64 _nextId = 0;

		private static uint64 GetNextId()
		{
			return _nextId++;
		}

		public ~this()
		{
			App.[Friend]DeleteComponentsOfEntity(this);
		}

		static ~this()
		{
			delete EntityStore;
		}
	}
}
