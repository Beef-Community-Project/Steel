namespace AceEngine.Events
{
	public abstract class MouseButtonEvent : Event
	{
		public override EventCategory Category => .Input | .Mouse | .MouseButton;

		public int Button { get; private set; }

		protected this(int button)
		{
			Button = button;
		}
	}
}
