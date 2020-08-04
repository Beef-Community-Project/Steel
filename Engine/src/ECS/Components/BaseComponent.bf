using System;

namespace SteelEngine.ECS.Components
{
	typealias ComponentId = uint64;
	/// <summary>
	/// Abstract class defining all Components.
	/// A class derived from Component will be managed by an appropriate <see cref="SteelEngine.ECS.Systems.System"/>.
	/// </summary>
	public abstract class BaseComponent
	{
		public this(bool isEnabled = true, Entity parent = null)
		{
			Id = GetNextId();
			IsEnabled = isEnabled;
			Parent = parent;
		}

		/// <summary>
		/// Unique identifier for the Component.
		/// </summary>
		public ComponentId Id { get; private set; }

		/// <summary>
		/// Enabled Components are managed by their corresponding <see cref="SteelEngine.ECS.Systems.System"/>, otherwise the Component is ignored.
		/// </summary>
		public bool IsEnabled { get; set; }

		/// <summary>
		/// Uninitialized Components are initialized by their corresponding <see cref="SteelEngine.ECS.Systems.System"/>,
		/// otherwise the Component is initialized on the next <see cref="SteelEngine.ECS.Systems.System.Initialize"/>, <see cref="SteelEngine.ECS.Systems.System.PreUpdate"/>, or <see cref="SteelEngine.ECS.Systems.System.PostUpdate"/> methods.
		/// </summary>
		public bool IsInitialized { get; private set; }

		/// <summary>
		/// Each Component belongs to a <see cref="SteelEngine.ECS.Entity"/> and maintains a reference to the parent <see cref="SteelEngine.ECS.Entity"/>.
		/// </summary>
		public Entity Parent { get; set; }

		public bool IsQueuedForDeletion { get; private set; }

		private static ComponentId _nextId = 0;

		private static ComponentId GetNextId()
		{
			return _nextId++;
		}
	}
}
