using System;
using SteelEngine.Events;

namespace SteelEngine
{
	public class Layer
	{
		protected String mDebugName ~ delete _;

		public this(StringView name = "Layer")
		{
			mDebugName = new String(name);
		}

		public virtual void OnAttach() {};
		public virtual void OnDetach() {};
		public virtual void OnUpdate() {};
		public virtual void OnEvent(Event event) {};
	}
}
