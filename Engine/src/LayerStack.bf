using System.Collections;
using System;

namespace SteelEngine
{
	public class LayerStack : IEnumerable<Layer>
	{
		private List<Layer> _layers = new .();
		private int _layerInsert = 0;

		public ~this()
		{
			for (var layer in _layers)
			{
				layer.OnDetach();
				delete layer;
			}

			delete _layers;
		}

		public void PushLayer(Layer layer)
		{
			_layers.Insert(_layerInsert++, layer);
			layer.OnAttach();
		}

		public void PushOverlay(Layer layer)
		{
			_layers.Add(layer);
			layer.OnAttach();
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
