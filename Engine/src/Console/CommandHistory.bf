using System;

namespace SteelEngine.Console
{
	class CommandHistory
	{
		private String[] _history ~ DeleteContainerAndItems!(_);
		private int _addIndex;
		private int _pos;

		public int Count => _addIndex;

		public this(int maxCount)
		{
			_history = new String[maxCount];
		}

		public void Add(StringView line)
		{
			if (_addIndex >= _history.Count)
			{
				delete _history[0];

				int prev = 0;
				int cur = 1;
				for (; cur < _history.Count; cur++)
				{
					_history[prev] = _history[cur];
					prev++;
				}

				_history[cur] = new .(line);
			}
			else
			{
				_history[_addIndex++] = new .(line);
			}
		}
		
		public StringView HistoryUp()
		{
			if (_pos >= _history.Count - 1)
				return default;

			return AtIndex(++_pos);
		}

		public StringView HistoryDown()
		{
			if (_pos <= 0)
				return default;

			return AtIndex(--_pos);
		}

		public StringView AtIndex(int index)
		{
			if (index < 0 || index >= Count)
				return default;

			return _history[index];
		}	
	}
}
