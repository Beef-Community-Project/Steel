using System;
using SteelEngine.Events;

namespace SteelEngine
{
	public class Layer
	{
		public bool DeleteOnDetach = false;

		protected String _debugName ~ delete _;

		public this(StringView name = "Layer")
		{
			_debugName = new String(name);
		}

		protected virtual void OnAttach() {};
		protected virtual void OnDetach() {};
		protected virtual void OnUpdate() {};
		protected virtual void OnEvent(Event event) {};
	}
}
