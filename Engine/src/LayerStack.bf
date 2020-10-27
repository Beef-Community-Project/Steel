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
				layer.[Friend]OnDetach();

				if (layer.DeleteOnDetach)
					delete layer;
			}

			delete _layers;
		}

		public void PushLayer<T>() where T : Layer
		{
			var layer = new T();
			layer.DeleteOnDetach = true;
			_layers.Insert(_layerInsert++, layer);
			layer.[Friend]OnAttach();
		}

		public void PushOverlay<T>() where T : Layer
		{
			var overlay = new T();
			overlay.DeleteOnDetach = true;
			_layers.Add(overlay);
			overlay.[Friend]OnAttach();
		}

		public void PushLayer(Layer layer)
		{
			_layers.Insert(_layerInsert++, layer);
			layer.[Friend]OnAttach();
		}

		public void PushOverlay(Layer overlay)
		{
			_layers.Add(overlay);
			overlay.[Friend]OnAttach();
		}

		public void PopLayer()
		{
			_layerInsert--;
			_layers.GetAndRemove(_layers[_layerInsert]).Get().[Friend]OnDetach();
		}

		public void PopOverlay()
		{
			if (_layers.Count > _layerInsert)
				_layers.PopBack().[Friend]OnDetach();
		}

		public void RemoveLayer(StringView debugName)
		{
			for (int i = 0; i < _layerInsert; i++)
			{
				if (_layers[i].[Friend]_debugName == debugName)
				{
					RemoveAt(i);
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
					RemoveAt(i);
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
					RemoveAt(i);
					_layerInsert--;
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
					RemoveAt(i);
					break;
				}
			}
		}

		private void RemoveAt(int index)
		{
			var layer = _layers.GetAndRemove(_layers[index]).Get();
			layer.[Friend]OnDetach();
			delete layer;
		}

		public List<Layer>.Enumerator GetEnumerator()
		{
			return _layers.GetEnumerator();
		}
	}
}
