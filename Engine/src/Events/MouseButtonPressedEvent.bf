using System;

namespace AceEngine.Events
{
	public class MouseButtonPressedEvent : MouseButtonEvent
	{
		public override EventType EventType => .MouseButtonPressed;

		public this(int button) : base(button) {}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("MouseButtonPressedEvent: {}", Button);
		}
	}
}
