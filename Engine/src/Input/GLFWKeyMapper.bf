using System;
using System.Collections;

namespace SteelEngine.Input
{
	public static class GLFWKeyMapper
	{
		const int GLFW_KEY_SPACE = 32;
		const int GLFW_KEY_APOSTROPHE = 39;
		const int GLFW_KEY_COMMA = 44;
		const int GLFW_KEY_MINUS = 45;
		const int GLFW_KEY_PERIOD = 46;
		const int GLFW_KEY_SLASH = 47;
		const int GLFW_KEY_0 = 48;
		const int GLFW_KEY_1 = 49;
		const int GLFW_KEY_2 = 50;
		const int GLFW_KEY_3 = 51;
		const int GLFW_KEY_4 = 52;
		const int GLFW_KEY_5 = 53;
		const int GLFW_KEY_6 = 54;
		const int GLFW_KEY_7 = 55;
		const int GLFW_KEY_8 = 56;
		const int GLFW_KEY_9 = 57;
		const int GLFW_KEY_SEMICOLON = 59;
		const int GLFW_KEY_EQUAL = 61;
		const int GLFW_KEY_A = 65;
		const int GLFW_KEY_B = 66;
		const int GLFW_KEY_C = 67;
		const int GLFW_KEY_D = 68;
		const int GLFW_KEY_E = 69;
		const int GLFW_KEY_F = 70;
		const int GLFW_KEY_G = 71;
		const int GLFW_KEY_H = 72;
		const int GLFW_KEY_I = 73;
		const int GLFW_KEY_J = 74;
		const int GLFW_KEY_K = 75;
		const int GLFW_KEY_L = 76;
		const int GLFW_KEY_M = 77;
		const int GLFW_KEY_N = 78;
		const int GLFW_KEY_O = 79;
		const int GLFW_KEY_P = 80;
		const int GLFW_KEY_Q = 81;
		const int GLFW_KEY_R = 82;
		const int GLFW_KEY_S = 83;
		const int GLFW_KEY_T = 84;
		const int GLFW_KEY_U = 85;
		const int GLFW_KEY_V = 86;
		const int GLFW_KEY_W = 87;
		const int GLFW_KEY_X = 88;
		const int GLFW_KEY_Y = 89;
		const int GLFW_KEY_Z = 90;
		const int GLFW_KEY_LEFT_BRACKET = 91;
		const int GLFW_KEY_BACKSLASH = 92;
		const int GLFW_KEY_RIGHT_BRACKET = 93;
		const int GLFW_KEY_GRAVE_ACCENT = 96;
		const int GLFW_KEY_WORLD_1 = 161;
		const int GLFW_KEY_WORLD_2 = 162;
		const int GLFW_KEY_ESCAPE = 256;
		const int GLFW_KEY_ENTER = 257;
		const int GLFW_KEY_TAB = 258;
		const int GLFW_KEY_BACKSPACE = 259;
		const int GLFW_KEY_INSERT = 260;
		const int GLFW_KEY_DELETE = 261;
		const int GLFW_KEY_RIGHT = 262;
		const int GLFW_KEY_LEFT = 263;
		const int GLFW_KEY_DOWN = 264;
		const int GLFW_KEY_UP = 265;
		const int GLFW_KEY_PAGE_UP = 266;
		const int GLFW_KEY_PAGE_DOWN = 267;
		const int GLFW_KEY_HOME = 268;
		const int GLFW_KEY_END = 269;
		const int GLFW_KEY_CAPS_LOCK = 280;
		const int GLFW_KEY_SCROLL_LOCK = 281;
		const int GLFW_KEY_NUM_LOCK = 282;
		const int GLFW_KEY_PRINT_SCREEN = 283;
		const int GLFW_KEY_PAUSE = 284;
		const int GLFW_KEY_F1 = 290;
		const int GLFW_KEY_F2 = 291;
		const int GLFW_KEY_F3 = 292;
		const int GLFW_KEY_F4 = 293;
		const int GLFW_KEY_F5 = 294;
		const int GLFW_KEY_F6 = 295;
		const int GLFW_KEY_F7 = 296;
		const int GLFW_KEY_F8 = 297;
		const int GLFW_KEY_F9 = 298;
		const int GLFW_KEY_F10 = 299;
		const int GLFW_KEY_F11 = 300;
		const int GLFW_KEY_F12 = 301;
		const int GLFW_KEY_F13 = 302;
		const int GLFW_KEY_F14 = 303;
		const int GLFW_KEY_F15 = 304;
		const int GLFW_KEY_F16 = 305;
		const int GLFW_KEY_F17 = 306;
		const int GLFW_KEY_F18 = 307;
		const int GLFW_KEY_F19 = 308;
		const int GLFW_KEY_F20 = 309;
		const int GLFW_KEY_F21 = 310;
		const int GLFW_KEY_F22 = 311;
		const int GLFW_KEY_F23 = 312;
		const int GLFW_KEY_F24 = 313;
		const int GLFW_KEY_F25 = 314;
		const int GLFW_KEY_KP_0 = 320;
		const int GLFW_KEY_KP_1 = 321;
		const int GLFW_KEY_KP_2 = 322;
		const int GLFW_KEY_KP_3 = 323;
		const int GLFW_KEY_KP_4 = 324;
		const int GLFW_KEY_KP_5 = 325;
		const int GLFW_KEY_KP_6 = 326;
		const int GLFW_KEY_KP_7 = 327;
		const int GLFW_KEY_KP_8 = 328;
		const int GLFW_KEY_KP_9 = 329;
		const int GLFW_KEY_KP_DECIMAL = 330;
		const int GLFW_KEY_KP_DIVIDE = 331;
		const int GLFW_KEY_KP_MULTIPLY = 332;
		const int GLFW_KEY_KP_SUBTRACT = 333;
		const int GLFW_KEY_KP_ADD = 334;
		const int GLFW_KEY_KP_ENTER = 335;
		const int GLFW_KEY_KP_EQUAL = 336;
		const int GLFW_KEY_LEFT_SHIFT = 340;
		const int GLFW_KEY_LEFT_CONTROL = 341;
		const int GLFW_KEY_LEFT_ALT = 342;
		const int GLFW_KEY_LEFT_SUPER = 343;
		const int GLFW_KEY_RIGHT_SHIFT = 344;
		const int GLFW_KEY_RIGHT_CONTROL = 345;
		const int GLFW_KEY_RIGHT_ALT = 346;
		const int GLFW_KEY_RIGHT_SUPER = 347;
		const int GLFW_KEY_MENU = 348;

		static Dictionary<int, KeyCode> _keyCodeMap = new Dictionary<int, KeyCode>()
		{
			(GLFW_KEY_SPACE, KeyCode.Space),	// KeyCode needs to be here otherwise compiler can't infer the type.
			(GLFW_KEY_APOSTROPHE, .Quote),		
			(GLFW_KEY_COMMA, .Comma),
			(GLFW_KEY_MINUS, .Minus),
			(GLFW_KEY_PERIOD, .Period),
			(GLFW_KEY_SLASH, .Slash),

			(GLFW_KEY_0, .Alpha0),
			(GLFW_KEY_1, .Alpha1),
			(GLFW_KEY_2, .Alpha2),
			(GLFW_KEY_3, .Alpha3),
			(GLFW_KEY_4, .Alpha4),
			(GLFW_KEY_5, .Alpha5),
			(GLFW_KEY_6, .Alpha6),
			(GLFW_KEY_7, .Alpha7),
			(GLFW_KEY_8, .Alpha8),
			(GLFW_KEY_9, .Alpha9),

			(GLFW_KEY_SEMICOLON, .Semicolon),
			(GLFW_KEY_EQUAL, .Equals),

			(GLFW_KEY_A, .A),
			(GLFW_KEY_B, .B),
			(GLFW_KEY_C, .C),
			(GLFW_KEY_D, .D),
			(GLFW_KEY_E, .E),
			(GLFW_KEY_F, .F),
			(GLFW_KEY_G, .G),
			(GLFW_KEY_H, .H),
			(GLFW_KEY_I, .I),
			(GLFW_KEY_J, .J),
			(GLFW_KEY_K, .K),
			(GLFW_KEY_L, .L),
			(GLFW_KEY_M, .M),
			(GLFW_KEY_N, .N),
			(GLFW_KEY_O, .O),
			(GLFW_KEY_P, .P),
			(GLFW_KEY_Q, .Q),
			(GLFW_KEY_R, .R),
			(GLFW_KEY_S, .S),
			(GLFW_KEY_T, .T),
			(GLFW_KEY_U, .U),
			(GLFW_KEY_V, .V),
			(GLFW_KEY_W, .W),
			(GLFW_KEY_X, .X),
			(GLFW_KEY_Y, .Y),
			(GLFW_KEY_Z, .Z),

			(GLFW_KEY_LEFT_BRACKET, .LeftBracket),
			(GLFW_KEY_BACKSLASH, .Backslash),
			(GLFW_KEY_RIGHT_BRACKET, .RightBracket),

			(GLFW_KEY_GRAVE_ACCENT, .BackQuote),		
			(GLFW_KEY_WORLD_1, .World1),				
			(GLFW_KEY_WORLD_2, .None),					// @TODO

			(GLFW_KEY_ESCAPE, .Escape),
			(GLFW_KEY_ENTER, .Return),
			(GLFW_KEY_TAB, .Tab),
			(GLFW_KEY_BACKSPACE, .Backspace),
			(GLFW_KEY_INSERT, .Insert),
			(GLFW_KEY_DELETE, .Delete),

			(GLFW_KEY_RIGHT, .RightArrow),
			(GLFW_KEY_LEFT, .LeftArrow),
			(GLFW_KEY_DOWN, .DownArrow),
			(GLFW_KEY_UP, .UpArrow),

			(GLFW_KEY_PAGE_UP, .PageUp),
			(GLFW_KEY_PAGE_DOWN, .PageDown),
			(GLFW_KEY_HOME, .Home),
			(GLFW_KEY_END, .End),
			(GLFW_KEY_CAPS_LOCK, .CapsLock),
			(GLFW_KEY_SCROLL_LOCK, .ScrollLock),
			(GLFW_KEY_NUM_LOCK, .NumLock),
			(GLFW_KEY_PRINT_SCREEN, .Print),
			(GLFW_KEY_PAUSE, .Pause),

			(GLFW_KEY_F1, .F1),
			(GLFW_KEY_F2, .F2),
			(GLFW_KEY_F3, .F3),
			(GLFW_KEY_F4, .F4),
			(GLFW_KEY_F5, .F5),
			(GLFW_KEY_F6, .F6),
			(GLFW_KEY_F7, .F7),
			(GLFW_KEY_F8, .F8),
			(GLFW_KEY_F9, .F9),
			(GLFW_KEY_F10, .F10),
			(GLFW_KEY_F11, .F11),
			(GLFW_KEY_F12, .F12),
			(GLFW_KEY_F13, .F13),
			(GLFW_KEY_F14, .F14),
			(GLFW_KEY_F15, .F15),
			(GLFW_KEY_F16, .F16),
			(GLFW_KEY_F17, .F17),
			(GLFW_KEY_F18, .F18),
			(GLFW_KEY_F19, .F19),
			(GLFW_KEY_F20, .F20),
			(GLFW_KEY_F21, .F21),
			(GLFW_KEY_F22, .F22),
			(GLFW_KEY_F23, .F23),
			(GLFW_KEY_F24, .F24),
			//	(GLFW_KEY_F25, .F25),	// @TODO - add F25?

			(GLFW_KEY_KP_0, .Keypad0),
			(GLFW_KEY_KP_1, .Keypad1),
			(GLFW_KEY_KP_2, .Keypad2),
			(GLFW_KEY_KP_3, .Keypad3),
			(GLFW_KEY_KP_4, .Keypad4),
			(GLFW_KEY_KP_5, .Keypad5),
			(GLFW_KEY_KP_6, .Keypad6),
			(GLFW_KEY_KP_7, .Keypad7),
			(GLFW_KEY_KP_8, .Keypad8),
			(GLFW_KEY_KP_9, .Keypad9),
			(GLFW_KEY_KP_DECIMAL, .KeypadPeriod),
			(GLFW_KEY_KP_DIVIDE, .KeypadDivide),
			(GLFW_KEY_KP_MULTIPLY, .KeypadMultiply),
			(GLFW_KEY_KP_SUBTRACT, .KeypadMinus),
			(GLFW_KEY_KP_ADD, .KeypadPlus),
			(GLFW_KEY_KP_ENTER, .KeypadEnter),
			(GLFW_KEY_KP_EQUAL, .KeypadEquals),

			(GLFW_KEY_LEFT_SHIFT, .LeftShift),
			(GLFW_KEY_LEFT_CONTROL, .LeftControl),
			(GLFW_KEY_LEFT_ALT, .LeftAlt),
			(GLFW_KEY_LEFT_SUPER, .LeftWindows),	// @TODO - its platform dependant
			(GLFW_KEY_RIGHT_SHIFT, .RightShift),
			(GLFW_KEY_RIGHT_CONTROL, .RightControl),
			(GLFW_KEY_RIGHT_ALT, .RightAlt),
			(GLFW_KEY_RIGHT_SUPER, .LeftWindows),	// @TODO
			(GLFW_KEY_MENU, .Menu),
		} ~ delete _;

		public static KeyCode MapKeyboardKey(int key)
		{
			KeyCode kc;
			if(_keyCodeMap.TryGetValue(key, out kc))
			{
				return kc;
			}

			return .None;
		}

		public static KeyCode MapMouseButton(int button)
		{
			switch(button)
			{
			case 0: return .Mouse0;
			case 1: return .Mouse1;
			case 2: return .Mouse2;
			case 3: return .Mouse3;
			case 4: return .Mouse4;
			case 5: return .Mouse5;
			case 6: return .Mouse6;
			}

			return .None;
		}
	}
}
