using System;

namespace AceEngine.Events
{
	public class MouseMovedEvent : Event
	{
		public override EventType EventType => .MouseMoved;
		public override EventCategory Category => .Input | .Mouse;

		public float PositionX { get; private set; }
		public float PositionY { get; private set; }

		public this(float x, float y)
		{
			PositionX = x;
			PositionY = y;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("MouseMovedEvent: {}, {}", PositionX, PositionY);
		}
	}
}
