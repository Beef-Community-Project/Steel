using System.Collections;

namespace SteelEngine
{
	public class LayerStack
	{
		private List<Layer> _layers = new .() ~ DeleteContainerAndItems!(_);
		private int _layerInsert = 0;

		public void PushLayer(Layer layer)
		{
			_layers.Insert(_layerInsert++, layer);
		}

		public void PushOverlay(Layer overlay)
		{
			_layers.Add(overlay);
		}

		public void PopLayer(Layer layer)
		{
			_layers.Remove(layer);
			_layerInsert--;
		}

		public void PopOverlay(Layer overlay)
		{
			_layers.Remove(overlay);
		}
	}
}
