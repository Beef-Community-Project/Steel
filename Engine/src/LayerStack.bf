using System.Collections;
using System;

namespace SteelEngine
{
	public class LayerStack : IEnumerable<Layer>
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

		public void PopLayer(StringView debugName = "")
		{
			if (debugName != "")
			{
				for (int i = 0; i < _layerInsert; i++)
				{
					if (_layers[i].[Friend]_debugName == debugName)
					{
						_layers.RemoveAt(i);
						_layerInsert--;
						break;
					}
				}	
			}
			else
			{
				_layers.RemoveAt(--_layerInsert);
			}
		}

		public void PopOverlay(StringView debugName)
		{
			if (debugName != "")
			{
				for (int i = _layerInsert; i < _layers.Count; i++)
				{
					if (_layers[i].[Friend]_debugName == debugName)
					{
						_layers.RemoveAt(i);
						break;
					}
				}	
			}
			else
			{
				if (_layers.Count > _layerInsert)
					_layers.RemoveAt(_layers.Count - 1);
			}
		}

		public List<Layer>.Enumerator GetEnumerator()
		{
			return _layers.GetEnumerator();
		}
	}
}
