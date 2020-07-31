using System;

namespace Engine.Events
{
	public class MouseScrolledEvent : Event
	{
		public override EventType EventType => .MouseScrolled;
		public override EventCategory Category => .Input | .Mouse;

		public float OffsetX { get; private set; }
		public float OffsetY { get; private set; }

		public this(float offsetX, float offsetY)
		{
			OffsetX = offsetX;
			OffsetY = offsetY;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("MouseScrolledEvent: {}, {}", OffsetX, OffsetY);
		}
	}
}
