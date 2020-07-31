namespace SteelEngine.Events
{
	public class EventDispatcher
	{
		typealias EventFn<T> = delegate bool(T);

		private Event _event;

		public this(Event event)
		{
			_event = event;
		}

		public bool Dispatch<T>(EventFn<T> func) where T : Event
		{
			if (typeof(T) == _event.GetType())
			{
				_event.IsHandled = func.Invoke((T) _event);
				return true;
			}

			return false;
		}
	}
}
