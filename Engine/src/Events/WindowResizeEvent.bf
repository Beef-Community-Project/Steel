using System;

namespace SteelEngine.Events
{
	public class WindowResizeEvent : Event
	{
		public override EventType EventType => .WindowResize;
		public override EventCategory Category => .Application;

		public int Width { get; private set; }
		public int Height { get; private set; }

		public this(int width, int height)
		{
			Width = width;
			Height = height;
		}

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("WindowResizeEvent: {}, {}", Width, Height);
		}
	}
}
