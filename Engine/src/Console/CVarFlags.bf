namespace SteelEngine.Console
{
	enum CVarFlags
	{
		None = 0x0000,
		/// Can be executed only when cheats are enabled
		Cheat = 0x0001,
		/// Indicates that this CVar will change value on registration to match value in configuration file
		Config = 0x0002,
		/// This flag is set when CVar was present in configuration file
		WasInConfig = 0x0004,
		/// This flags is set when CVar value is changed after configuration file was loaded
		Changed = 0x0008,
		/// CVar won't show in console but its value can be changed through code
		Hidden = 0x0010,
		/// OnChange callback will always be called even when value didn't change
		AlwaysOnChange = 0x0020,
		/// Disable value check for enum variables
		Flags = 0x0040
	}
}
