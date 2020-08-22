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

		public void Add(StringView line)
		{
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

		public StringView At(int index)
		{
			// index 0 = empty string
			// index 1 = last addeded entry
			// index >= _Count =  first entry in history

			// @TODO(fusion) - revisit this code, have feeling this can be simplified

			if (index == 0)
				return default;

			if (_count < _history.Count)
				return _history[_addPos - index + 1];

			if (index >= _count)
				return _history[_addPos+1 % _count];

			var i = (_addPos - index + 1) % _count;
			if (i < 0)
				return _history[_count + i];

			return _history[i];

		}	
	}
}
