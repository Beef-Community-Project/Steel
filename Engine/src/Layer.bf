using System;
using SteelEngine.Events;

namespace SteelEngine
{
	public class Layer
	{
		protected String _debugName ~ delete _;

		public this(StringView name = "Layer")
		{
			_debugName = new String(name);
		}

		public virtual void OnAttach() {};
		public virtual void OnDetach() {};
		public virtual void OnUpdate() {};
		public virtual void OnEvent(Event event) {};
	}
}
