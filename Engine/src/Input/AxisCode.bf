namespace SteelEngine.Input
{
	public enum AxisCode
	{
		MouseX = 0,
		MouseY,
		MouseScroll,

		GamepadLeftStickX,
		GamepadLeftStickY,
		GamepadRightStickX,
		GamepadRightStickY,
		GamepadLeftTrigger,
		GamepadRightTrigger,

		MAX
	}

	public enum GamepadAxisCode : AxisCode
	{
		LeftStickX = (.)AxisCode.GamepadLeftStickX,
		LeftStickY = (.)AxisCode.GamepadLeftStickY,
		LeftTrigger = (.)AxisCode.GamepadLeftTrigger,
		RightStickX = (.)AxisCode.GamepadRightStickX,
		RightStickY = (.)AxisCode.GamepadRightStickY,
		RightTrigger = (.)AxisCode.GamepadRightTrigger,
	}
}
