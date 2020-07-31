using System;

namespace SteelEngine.Events
{
	public class KeyReleasedEvent : KeyEvent
	{
		public override EventType EventType => .KeyReleased;

		public this(int keycode) : base(keycode) {}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("KeyReleasedEvent: {}", KeyCode);
		}
	}
}
