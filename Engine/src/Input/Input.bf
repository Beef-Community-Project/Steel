using System;

namespace SteelEngine.Input
{
	public enum KeyEvent : uint8
	{
		Down = 0x01,
		Up = 0x02,
	}

	public class Input
	{
		static var _accumulatedEvents = KeyEvent[KeyCode.MAX]();
		static var _lastUpdateState = KeyStatus[KeyCode.MAX]();

		static void KeyEvent(KeyCode kc, KeyEvent ke)
		{
			_accumulatedEvents[kc.Underlying] |= ke;
		}

		static void Update()
		{
			for (int i = 0, let count = _accumulatedEvents.Count; i < count; i++)
			{
				let event = _accumulatedEvents[i];

				_lastUpdateState[i] &= ~(.Down | .Up);	// Clear up / down
				if (event.HasFlag(.Down))
				{
					_lastUpdateState[i] = .Down | .Hold;
				}

				if (event.HasFlag(.Up))
				{
					_lastUpdateState[i] = ( _lastUpdateState[i] & ~.Hold) | .Up;		// If key was pressed and released we probably want to unset the Hold flag but keep down flag.
				}
			}

			// Clear event accumulator
			_accumulatedEvents = default;
		}

		public static void ResetInput()
		{
			_accumulatedEvents = default;
			_lastUpdateState = default;
		}

		public static bool GetKeyDown(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Down);
		}

		public static bool GetKeyUp(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Up);
		}

		public static bool GetKey(KeyCode kc)
		{
			return _lastUpdateState[kc.Underlying].HasFlag(.Hold);
		}
	}
}
