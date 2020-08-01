using System.Collections;

namespace SteelEngine
{
	public class LayerStack
	{
		private List<Layer> mLayers = new .() ~ DeleteContainerAndItems!(_);
		private int mLayerInsert = 0;

		public void PushLayer(Layer layer)
		{
			mLayers.Insert(mLayerInsert++, layer);
		}

		public void PushOverlay(Layer overlay)
		{
			mLayers.Add(overlay);
		}

		public void PopLayer(Layer layer)
		{
			mLayers.Remove(layer);
			mLayerInsert--;
		}

		public void PopOverlay(Layer overlay)
		{
			mLayers.Remove(overlay);
		}
	}
}
