using System;

namespace AceEngine.Events
{
	public class KeyPressedEvent : KeyEvent
	{
		public override EventType EventType => .KeyPressed;

		public int RepeatCount { get; private set; }

		public this(int keycode, int repeatCount) : base(keycode)
		{
			RepeatCount = repeatCount;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("KeyPressedEvent: {} ({} repeats)", KeyCode, RepeatCount);
		}
	}
}
