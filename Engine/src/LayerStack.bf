using System.Collections;
using System;

namespace SteelEngine
{
	public class LayerStack : IEnumerable<Layer>
	{
		public bool AutoDeleteLayers;

		private List<Layer> _layers = new .();
		private int _layerInsert = 0;

		public this(bool autoDeleteLayers = true)
		{
			AutoDeleteLayers = autoDeleteLayers;
		}

		public ~this()
		{
			if (AutoDeleteLayers)
				ClearAndDeleteItems(_layers);
			delete _layers;
		}

		public void PushLayer(Layer layer)
		{
			_layers.Insert(_layerInsert++, layer);
		}

		public void PushOverlay(Layer overlay)
		{
			_layers.Add(overlay);
		}

		public void PopLayer()
		{
			_layerInsert--;
			_layers.RemoveAt(_layerInsert);
		}

		public void PopOverlay()
		{
			if (_layers.Count > _layerInsert)
				_layers.PopBack();
		}

		public void RemoveLayer(StringView debugName)
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

		public void RemoveOverlay(StringView debugName)
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

		public void RemoveLayer<T>() where T : Layer
		{
			for (int i = 0; i < _layerInsert; i++)
			{
				if (typeof(T) == _layers[i].GetType())
				{
					_layers.RemoveAt(i);
					return;
				}
			}
		}

		public void RemoveOverlay<T>() where T : Layer
		{
			for (int i = _layerInsert; i < _layers.Count; i++)
			{
				if (typeof(T) == _layers[i].GetType())
				{
					_layers.RemoveAt(i);
					break;
				}
			}
		}
		
		public void RemoveLayer(Layer layer)
		{
			for (int i = 0; i < _layerInsert; i++)
			{
				if (_layers[i] == layer)
				{
					_layers.RemoveAt(i);
					return;
				}
			}
		}

		public void RemoveOverlay(Layer layer)
		{
			for (int i = _layerInsert; i < _layers.Count; i++)
			{
				if (_layers[i] == layer)
				{
					_layers.RemoveAt(i);
					return;
				}
			}
		}

		public List<Layer>.Enumerator GetEnumerator()
		{
			return _layers.GetEnumerator();
		}
	}
}
