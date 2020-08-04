using System;
namespace SteelEngine.Input
{
	public class GamepadInfo
	{
		const let KEYCODE_START = KeyCode.GamepadA;
		const let KEYCODE_END = KeyCode.GamepadRightStick + 1;
		const let AXISCODE_START = AxisCode.LeftStickX;
		const let AXISCODE_END = AxisCode.RightTrigger + 1;

		const int NUMBER_OF_KEYS = int(KEYCODE_END-KEYCODE_START);
		const int NUMBER_OF_AXES = int(AXISCODE_END-AXISCODE_START);

		KeyEvent[NUMBER_OF_KEYS] _accumulatedKeyEvents;
		KeyState[NUMBER_OF_KEYS] _keyStates;
		float[NUMBER_OF_AXES] _axisValues;

		String _gamepadName ~ delete _;

		public StringView Name => _gamepadName;

		public void Update()
		{
			// Update Keys
			for (int i = 0; i < NUMBER_OF_KEYS; i++)
			{
				let event = _accumulatedKeyEvents[i];
				var newValue = _keyStates[i] & ~(.Down | .Up);	// Clear up / down flags

				// If we already have key state Hold we don't want to set Down again
				if (event.HasFlag(.Down) && !_keyStates[i].HasFlag(.Hold))
				{
					newValue = .Down | .Hold;								
				}

				// Up key flag can only be set if the key was down previous update
				if (event.HasFlag(.Up) && _keyStates[i].HasFlag(.Hold))
				{
					// If key was pressed and released we probably want to unset the Hold flag but keep down flag.
					newValue = ( _keyStates[i] & ~.Hold) | .Up;
				}

				_keyStates[i] = newValue;
			}

			// We set axis values each update so we don't need to update anything here
		}

		public void ResetInput()
		{
			_accumulatedKeyEvents = default;
			_keyStates = default;
			_axisValues = default;
		}

		static mixin CheckRange(AxisCode ac)
		{
			if(ac < AXISCODE_START || ac >= AXISCODE_END)
			{
				Log.Error("AxisCode '{0}' outside of mappable range!", ac);
				return default;
			}
		}

		static mixin CheckRange(KeyCode kc)
		{
			if(kc < KEYCODE_START || kc >= KEYCODE_END)
			{
				Log.Error("KeyCode '{0}' outside of mappable range!", kc);
				return default;
			}
		}

		public float GetAxis(AxisCode ac)
		{
			CheckRange!(ac);
			return _axisValues[(ac - AXISCODE_START).Underlying];
		}

		public bool GetKeyDown(KeyCode kc)
		{
			CheckRange!(kc);
			return _keyStates[(kc - KEYCODE_START).Underlying].HasFlag(.Down);
		}

		public bool GetKeyUp(KeyCode kc)
		{
			CheckRange!(kc);
			return _keyStates[(kc - KEYCODE_START).Underlying].HasFlag(.Up);
		}

		public bool GetKey(KeyCode kc)
		{
			CheckRange!(kc);
			return _keyStates[(kc - KEYCODE_START).Underlying].HasFlag(.Hold);
		}

		// Set functions are not called by user code
		// Don't see the need to add range checks in these
		void SetKey(KeyCode kc, KeyEvent ke)
		{
			_accumulatedKeyEvents[(kc - KEYCODE_START).Underlying] = ke;
		}

		void SetAxis(AxisCode ac, float value)
		{
			_axisValues[(int)(ac - AXISCODE_START)] = value;
		}

		public this(StringView gamepadName)
		{
			_gamepadName = new .(gamepadName);
		}
	}
}
