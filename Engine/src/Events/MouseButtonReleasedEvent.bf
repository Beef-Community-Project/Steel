using System;

namespace SteelEngine.Events
{
	public class MouseButtonReleasedEvent : MouseButtonEvent
	{
		public override EventType EventType => .MouseButtonReleased;

		public this(int button) : base(button) {}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("MouseButtonReleasedEvent: {}", Button);
		}
	}
}
