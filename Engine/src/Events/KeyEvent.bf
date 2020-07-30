using System;

namespace AceEngine.Events
{
	public abstract class KeyEvent : Event
	{
		public override EventCategory Category => .Input | .Keyboard;

		public int KeyCode { get; protected set; }

		protected this(int keycode)
		{
			KeyCode = keycode;
		}
	}
}
