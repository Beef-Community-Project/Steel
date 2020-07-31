using System;

namespace SteelEngine.Events
{
	public abstract class Event
	{
		public inline abstract EventType EventType { get; }
		public inline abstract EventCategory Category { get; }

		public bool IsHandled = false;

		public override void ToString(String strBuffer)
		{
			strBuffer.AppendF("{}Event", EventType);
		}

		public bool IsInCategory(EventCategory category)
		{
			return (int) Category & (int) category != 0;
		}
	}
}
