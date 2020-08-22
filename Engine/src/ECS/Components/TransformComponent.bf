using SteelEngine.Math;
using System;

namespace SteelEngine.ECS.Components
{
	[Reflect]
	public class TransformComponent : BaseComponent
	{
		public Vector3 Position { get; set; }
		public Vector3 Rotation { get; set; }
		public Vector3 Scale { get; set; }
	}
}
