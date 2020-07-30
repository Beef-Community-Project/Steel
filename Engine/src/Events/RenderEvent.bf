namespace AceEngine.Events
{
	public class RenderEvent : Event
	{
		public override EventType EventType => .Render;
		public override EventCategory Category => .Application;
	}
}
