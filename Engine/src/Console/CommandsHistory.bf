using System;

namespace SteelEngine.Console
{
	class CommandsHistory
	{
		private String[] _history ~  DeleteContainerAndItems!(_);
		private int _count = 0;
		private int _addPos = 0;

		private int _historyPos = 0;

		public this(int maxCount)
		{
			_history = new String[maxCount];
			for (var item in ref _history)
				item = new String();
		}

		public void Resize(int newSize)
		{
			if (newSize <= 0 || newSize == _history.Count)
				return;

			_historyPos = 0;

			String[] newHistory = new String[newSize];

			let count = Math.Min(newHistory.Count, _count);
			int i;
			for (i = 0; i < count; i++)
			{
				newHistory[i] = StringAt(i+1);
			}
			i++;
			if (i < _history.Count && newHistory.Count > _history.Count )
			{
				_history.CopyTo(newHistory, i, i, _history.Count - i);
				i = _history.Count;
			}	

			// Delete elements that did not fit into new history
			for (; i <= _count; i++)
				delete StringAt(i);
			for (i = _count; i < _history.Count; i++)
				delete _history[i];

			// Allocate elements that were not copied from old history
			for (i = _history.Count; i < newHistory.Count; i++)
				newHistory[i] = new String();

			_count = Math.Min(_count, newHistory.Count);
			_addPos = _count - 1;

			delete _history;
			_history = newHistory;
		}

		public void Add(StringView line)
		{
			_historyPos = 0;

			// Don't add line if it is same as last entry
			if(At(1).Equals(line))
				return;

			_addPos++;
			_count++;
			if (_addPos == _history.Count)
				_addPos = 0;

			if (_count > _history.Count)
				_count--;

			let item = _history[_addPos];
			item.Set(line);
		}
		
		public StringView HistoryUp()
		{
			if (_historyPos < _count)
				_historyPos++;

			return  At(_historyPos);
		}

		public StringView HistoryDown()
		{
			if (_historyPos > 0)
				_historyPos--;
			
			return  At(_historyPos);
		}

		protected String StringAt(int index)
		{
			// index 0 = empty string
			// index 1 = last added entry
			// index >= _Count =  first entry in history

			// @TODO(fusion) - revisit this code, have feeling this can be simplified

			if (index == 0)
				return default;

			if (_count < _history.Count)
				return _history[_addPos - Math.Min(_count, index) + 1];

			if (index >= _count)
				return _history[(_addPos+1) % _count];

			var i = (_addPos - index + 1) % _count;
			if (i < 0)
				return _history[_count + i];

			return _history[i];
		}

		public StringView At(int index) => StringAt(index);
	}
}
