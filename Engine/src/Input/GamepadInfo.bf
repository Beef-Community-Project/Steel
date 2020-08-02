using System;
namespace SteelEngine.Input
{
	public class GamepadInfo
	{
		const let KeyCodeStart = KeyCode.GamepadA;
		const let KeyCodeEnd = KeyCode.GamepadRightStick + 1;
		const let AxisCodeStart = GamepadAxisCode.LeftStickX;
		const let AxisCodeEnd = GamepadAxisCode.RightTrigger + 1;

		const int NUMBER_OF_KEYS = int(KeyCodeEnd-KeyCodeStart);
		const int NUMBER_OF_AXIS = int(AxisCodeEnd-AxisCodeStart);

		KeyEvent[NUMBER_OF_KEYS] _accumulatedKeyEvents;
		KeyStatus[NUMBER_OF_KEYS] _keyStates;
		float[NUMBER_OF_AXIS] _axisValues;

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
			_keyStates = default;
			_axisValues = default;
		}

		public float GetAxis(GamepadAxisCode ac)
		{
			System.Diagnostics.Debug.Assert(ac >= AxisCodeStart && ac < AxisCodeEnd);
			return _axisValues[(ac - AxisCodeStart).Underlying];
		}

		public bool GetKeyDown(KeyCode kc)
		{
			System.Diagnostics.Debug.Assert(kc >= KeyCodeStart && kc < KeyCodeEnd);
			return _keyStates[(kc - KeyCodeStart).Underlying].HasFlag(.Down);
		}

		public bool GetKeyUp(KeyCode kc)
		{
			System.Diagnostics.Debug.Assert(kc >= KeyCodeStart && kc < KeyCodeEnd);
			return _keyStates[(kc - KeyCodeStart).Underlying].HasFlag(.Up);
		}

		public bool GetKey(KeyCode kc)
		{
			System.Diagnostics.Debug.Assert(kc >= KeyCodeStart && kc < KeyCodeEnd);
			return _keyStates[(kc - KeyCodeStart).Underlying].HasFlag(.Hold);
		}

		void SetKey(KeyCode kc, KeyEvent ke)
		{
			System.Diagnostics.Debug.Assert(kc >= KeyCodeStart && kc < KeyCodeEnd);
			_accumulatedKeyEvents[(kc - KeyCodeStart).Underlying] = ke;
		}

		void SetAxis(GamepadAxisCode ac, float value)
		{
			System.Diagnostics.Debug.Assert(ac >= AxisCodeStart && ac <= AxisCodeEnd);
			_axisValues[(int)(ac - AxisCodeStart)] = value;
		}

		public this(StringView gamepadName)
		{
			_gamepadName = new .(gamepadName);
		}
	}
}
