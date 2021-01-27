using System.Collections;
using System.IO;
using System;
using System.Diagnostics;

namespace SteelEngine
{
	public delegate void LogCallback(LogLevel level, StringView message);

	public static class Log
	{
		public static LogLevel LogLevel = .Trace;

		public delegate void LogCallback(StringView str, LogLevel level);

		private static List<LogCallback> _callbacks = new .() ~ DeleteContainerAndItems!(_);

		public static void AddCallback(LogCallback callback) => _callbacks.Add(callback);

		public static void Trace(StringView format, params Object[] args) => Print(.Trace, format, params args);
		public static void Trace(Object arg) => Print(.Trace, "{}", arg);

		public static void Info(StringView format, params Object[] args) => Print(.Info, format, params args);
		public static void Info(Object arg) => Print(.Info, "{}", arg);

		public static void Warning(StringView format, params Object[] args) => Print(.Warning, format, params args);
		public static void Warning(Object arg) => Print(.Warning, "{}", arg);

		public static void Error(StringView format, params Object[] args) => Print(.Error, format, params args);
		public static void Error(Object arg) => Print(.Error, "{}", arg);

		public static void Fatal(StringView format, params Object[] args)
		{
			var message = scope String()..AppendF(format, params args);
			Print(.Fatal, message);
			Runtime.FatalError(message);
		}

		private static void Print(LogLevel level, StringView format, params Object[] args)
		{
			var time = scope String()..AppendF("{}:{}:{}", DateTime.Now.Minute, DateTime.Now.Second, DateTime.Now.Millisecond); // Format current time
			var message = scope String()..AppendF(format, params args); // Format users message
			var line = scope String()..AppendF("[{}] [{}] {}", time, level, message); // Format line to print

			for (var callback in _callbacks)
				callback(line, level);
		}
	}
}
