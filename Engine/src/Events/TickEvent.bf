namespace SteelEngine.Events
{
	public class TickEvent : Event
	{
		public override EventType EventType => .Tick;
		public override EventCategory Category => .Application;
	}
}
