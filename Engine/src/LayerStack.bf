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
			{
				for (var layer in _layers)
					layer.OnDetach();

				ClearAndDeleteItems(_layers);
			}

			delete _layers;
		}

		public void PushLayer(Layer layer)
		{
			_layers.Insert(_layerInsert++, layer);
			layer.OnAttach();
		}

		public void PushOverlay(Layer overlay)
		{
			_layers.Add(overlay);
			overlay.OnAttach();
		}

		public void PopLayer()
		{
			_layerInsert--;
			_layers.GetAndRemove(_layers[_layerInsert]).Get().OnDetach();
		}

		public void PopOverlay()
		{
			if (_layers.Count > _layerInsert)
				_layers.PopBack().OnDetach();
		}

		public void RemoveLayer(StringView debugName)
		{
			for (int i = 0; i < _layerInsert; i++)
			{
				if (_layers[i].[Friend]_debugName == debugName)
				{
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
					_layers.GetAndRemove(_layers[i]).Get().OnDetach();
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
