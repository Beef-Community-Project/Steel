namespace SteelEngine.Events
{
	public class WindowCloseEvent : Event
	{
		public override EventType EventType => .WindowClose;
		public override EventCategory Category => .Application;
	}
}
