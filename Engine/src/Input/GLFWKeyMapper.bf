using System;
using System.Collections;
using glfw_beef;

namespace SteelEngine.Input
{
	public static class GLFWKeyMapper
	{
		static Dictionary<GlfwInput.Key, KeyCode> _keyCodeMap = new Dictionary<GlfwInput.Key, KeyCode>()
		{
			(GlfwInput.Key.Space, KeyCode.Space),	// KeyCode needs to be here otherwise compiler can't infer the type.
			(.Apostrophe, .Quote),		
			(.Comma, .Comma),
			(.Minus, .Minus),
			(.Period, .Period),
			(.Slash, .Slash),

			(.Num0, .Alpha0),
			(.Num1, .Alpha1),
			(.Num2, .Alpha2),
			(.Num3, .Alpha3),
			(.Num4, .Alpha4),
			(.Num5, .Alpha5),
			(.Num6, .Alpha6),
			(.Num7, .Alpha7),
			(.Num8, .Alpha8),
			(.Num9, .Alpha9),

			(.Smicolon, .Semicolon),
			(.Equal, .Equals),

			(.A, .A),
			(.B, .B),
			(.C, .C),
			(.D, .D),
			(.E, .E),
			(.F, .F),
			(.G, .G),
			(.H, .H),
			(.I, .I),
			(.J, .J),
			(.K, .K),
			(.L, .L),
			(.M, .M),
			(.N, .N),
			(.O, .O),
			(.P, .P),
			(.Q, .Q),
			(.R, .R),
			(.S, .S),
			(.T, .T),
			(.U, .U),
			(.V, .V),
			(.W, .W),
			(.X, .X),
			(.Y, .Y),
			(.Z, .Z),

			(.LeftBracket, .LeftBracket),
			(.Backslash, .Backslash),
			(.RightBracket, .RightBracket),

			(.GraveAccent, .BackQuote),		
			(.World1, .World1),				
			(.World2, .None),					// @TODO

			(.Escape, .Escape),
			(.Enter, .Return),
			(.Tab, .Tab),
			(.Backspace, .Backspace),
			(.Insert, .Insert),
			(.Delete, .Delete),

			(.Right, .RightArrow),
			(.Left, .LeftArrow),
			(.Down, .DownArrow),
			(.Up, .UpArrow),

			(.PageUp, .PageUp),
			(.PageDown, .PageDown),
			(.Home, .Home),
			(.End, .End),
			(.CapsLock, .CapsLock),
			(.ScrollLock, .ScrollLock),
			(.NumLock, .NumLock),
			(.PrintScreen, .Print),
			(.Pause, .Pause),

			(.F1, .F1),
			(.F2, .F2),
			(.F3, .F3),
			(.F4, .F4),
			(.F5, .F5),
			(.F6, .F6),
			(.F7, .F7),
			(.F8, .F8),
			(.F9, .F9),
			(.F10, .F10),
			(.F11, .F11),
			(.F12, .F12),
			(.F13, .F13),
			(.F14, .F14),
			(.F15, .F15),
			(.F16, .F16),
			(.F17, .F17),
			(.F18, .F18),
			(.F19, .F19),
			(.F20, .F20),
			(.F21, .F21),
			(.F22, .F22),
			(.F23, .F23),
			(.F24, .F24),

			(.Kp0, .Keypad0),
			(.Kp1, .Keypad1),
			(.Kp2, .Keypad2),
			(.Kp3, .Keypad3),
			(.Kp4, .Keypad4),
			(.Kp5, .Keypad5),
			(.Kp6, .Keypad6),
			(.Kp7, .Keypad7),
			(.Kp8, .Keypad8),
			(.Kp9, .Keypad9),
			(.KpDecimal, .KeypadPeriod),
			(.KpDivide, .KeypadDivide),
			(.KpMultiply, .KeypadMultiply),
			(.KpSubtract, .KeypadMinus),
			(.KpAdd, .KeypadPlus),
			(.KpEnter, .KeypadEnter),
			(.KpEqual, .KeypadEquals),

			(.LeftShift, .LeftShift),
			(.LeftControl, .LeftControl),
			(.LeftAlt, .LeftAlt),
			(.LeftSuper, .LeftSuper),	// @TODO - its platform dependent
			(.RightShift, .RightShift),
			(.RightControl, .RightControl),
			(.RightAlt, .RightAlt),
			(.RightSuper, .RightSuper),	// @TODO
			(.Menu, .Menu),
		} ~ delete _;

		public static KeyCode MapKeyboardKey(GlfwInput.Key key)
		{
			KeyCode kc;
			if (_keyCodeMap.TryGetValue(key, out kc))
			{
				return kc;
			}

			return .None;
		}

		public static KeyCode MapMouseButton(GlfwInput.MouseButton button)
		{
			switch (button)
			{
				case .Button1: return .Mouse0;
				case .Button2: return .Mouse1;
				case .Button3: return .Mouse2;
				case .Button4: return .Mouse3;
				case .Button5: return .Mouse4;
				case .Button6: return .Mouse5;
				case .Button7: return .Mouse6;
				case .Button8: return .Mouse7;
				default: return .None;
			}
		}

		public static KeyCode MapGamepadButton(GlfwInput.GamepadButton button)
		{
			switch (button)
			{
				case .A: return .GamepadA;
				case .B: return .GamepadB;
				case .X: return .GamepadX;
				case .Y: return .GamepadY;
				case .DPadLeft: return .GamepadLeft;
				case .DPadRight: return .GamepadRight;
				case .DPadUp: return .GamepadUp;
				case .DPadDown: return .GamepadDown;
				case .LeftThumb: return .GamepadLeftStick;
				case .RightThumb: return .GamepadRightStick;
				case .Start: return .GamepadStart;
				case .Guide: return .GamepadHome;
				case .Back: return .GamepadSelect;
				case .LeftBumper: return .GamepadL1;
				case .RightBumper: return .GamepadR1;
				default: return .None;
			}
		}
	}
}
