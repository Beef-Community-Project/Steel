using System;
using System.Collections;
using SteelEngine.Events;
using SteelEngine.Window;
using glfw_beef;

namespace SteelEngine.Input
{
	public class GLFWInputSystem
	{
		HashSet<int> _connectedGamepads = new HashSet<int>() ~ delete _;

		public Result<void> Initialize()
		{
			Glfw.SetJoystickCallback(new => OnJoystickEvent);

			for (var i = GlfwInput.Joystick.Joystick1; i < GlfwInput.Joystick.Last; i++)
			{
				if (Glfw.JoystickIsGamepad((.)i))
				{
					OnJoystickEvent((.)i, .Connected);
				}
			}

			return .Ok;
		}

		public void Update()
		{
			for (var pad in _connectedGamepads)
			{
				glfw_beef.GlfwGamepadState state = ?;
				if (!Glfw.GetGamepadState(pad, ref state))
					continue;

				Input.[Friend]GamepadAxisEvent((.)pad, .LeftStickX, state.axes[(int)GlfwInput.GamepadAxis.LeftX]);
				Input.[Friend]GamepadAxisEvent((.)pad, .LeftStickY, state.axes[(int)GlfwInput.GamepadAxis.LeftY]);
				Input.[Friend]GamepadAxisEvent((.)pad, .LeftTrigger, state.axes[(int)GlfwInput.GamepadAxis.LeftTrigger]);
				Input.[Friend]GamepadAxisEvent((.)pad, .RightStickX, state.axes[(int)GlfwInput.GamepadAxis.RightX]);
				Input.[Friend]GamepadAxisEvent((.)pad, .RightStickY, state.axes[(int)GlfwInput.GamepadAxis.RightY]);
				Input.[Friend]GamepadAxisEvent((.)pad, .RightTrigger, state.axes[(int)GlfwInput.GamepadAxis.RightTrigger]);

				for (int i = 0; i < state.buttons.Count; i++)
				{
					let keycode = GLFWKeyMapper.MapGamepadButton((.)i);
					switch (state.buttons[i])
					{
						case .Press: Input.[Friend]GamepadKeyEvent((.)pad, keycode, .Down);
						case .Release: Input.[Friend]GamepadKeyEvent((.)pad, keycode, .Up);
						case .Repeat: break;
					}
				}

				// @TODO(fusion): handle keys which are not in gamepad state
				/*int32 count = ?;
				let buttons = Glfw.GetJoystickButtons(pad, ref count);
				for (int i = 0; i < count; i++)
				{
					
					switch (buttons[i])
					{
						case .Press: Log.Info("{0}", i);
 						default: break;
					}
				}*/
			}

			Input.[Friend]Update();
		}

		public void OnEvent(Event event)
		{
			var dispatcher = scope EventDispatcher(event);
			dispatcher.Dispatch<KeyPressedEvent>(scope => OnKeyPressed);
			dispatcher.Dispatch<KeyReleasedEvent>(scope => OnKeyRelease);
			dispatcher.Dispatch<MouseButtonPressedEvent>(scope => OnMouseButtonPressed);
			dispatcher.Dispatch<MouseButtonReleasedEvent>(scope => OnMouseButtonReleased);
			dispatcher.Dispatch<MouseMovedEvent>(scope => OnMouseMoved);
			dispatcher.Dispatch<MouseScrolledEvent>(scope => OnMouseScrolled);

			if (event.EventType == .WindowLostFocus)
			{
				Input.ResetInput();
			}
		}

		private void OnJoystickEvent(int id, GlfwInput.JoystickEvent event)
		{
			switch (event)
			{
				case .Connected:
				{
					// Ignore the connected device if it's not gamepad
					if (!Glfw.JoystickIsGamepad(id)) return;

					var deviceName = scope String();
					// GetJoystickName seems to return better name than GetGamepadName
					Glfw.GetJoystickName(id, deviceName);
					Input.[Friend]GamepadConnected((Input.GamepadId)id, deviceName);
					_connectedGamepads.Add(id);
					Log.Info("Gamepad '{0}' connected with id: {1}", deviceName, id);
				}
				case .Disconnected:
				{
					Input.[Friend]GamepadDisconnected((Input.GamepadId)id);
					_connectedGamepads.Remove(id);
				}
			}
		}

		private bool OnKeyPressed(KeyPressedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey((.)event.KeyCode), .Down);
			return true;
		}

		private bool OnKeyRelease(KeyReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapKeyboardKey((.)event.KeyCode), .Up);
			return true;
		}

		private bool OnMouseButtonPressed(MouseButtonPressedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton((.)event.Button), .Down);
			return true;
		}

		private bool OnMouseButtonReleased(MouseButtonReleasedEvent event)
		{
			Input.[Friend]KeyEvent(GLFWKeyMapper.MapMouseButton((.)event.Button), .Up);
			return true;
		}

		private bool OnMouseMoved(MouseMovedEvent event)
		{
			Input.[Friend]UpdateMousePosition((.)event.PositionX, (.)event.PositionY);
			return true;
		}

		private bool OnMouseScrolled(MouseScrolledEvent event)
		{
			Input.[Friend]AxisEvent(.MouseScroll, event.OffsetY);
			return true;
		}

	}
}
