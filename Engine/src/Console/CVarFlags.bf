namespace SteelEngine.Console
{
	enum CVarFlags
	{
		None = 0x0000,
		// Can be executed only when sv.cheats is True
		Cheat = 0x0001,
		// Indicates that this CVar will change value on registration to match value in config file
		Config = 0x0002,
		// This flag is set when CVar was present in config file
		WasInConfig = 0x0004,
		// CVar value was changed after config load
		Changed = 0x0008,
		// CVar won't show in console but can be changed through code
		Hidden = 0x0010,
	}
}
