namespace AceEngine.Events
{
	public class EventDispatcher
	{
		typealias EventFn<T> = delegate bool(T);

		private Event mEvent;

		public this(Event event)
		{
			mEvent = event;
		}

		public bool Dispatch<T>(EventFn<T> func) where T : Event
		{
			if (typeof(T) == mEvent.GetType())
			{
				mEvent.IsHandled = func.Invoke((T) mEvent);
				return true;
			}

			return false;
		}
	}
}
