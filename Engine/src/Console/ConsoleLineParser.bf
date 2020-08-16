using System;
using System.Collections;

namespace SteelEngine.Console
{
	class ConsoleLineParser
	{
		const char8 SEPARATOR_CHAR = ';';
		const char8 QUOTE_CHAR = '"';

		static void SkipWhitespace(StringView input, ref int i)
		{
			while (i < input.Length)
			{
				if (!input[i].IsWhiteSpace)
					break;

				i++;
			}
		}

		static StringView? ParseNormal(StringView input, ref int i)
		{
			let startPos = i;
			while (i < input.Length)
			{
				if (input[i].IsWhiteSpace || input[i] == SEPARATOR_CHAR)
					break;

				i++;
			}

			if (startPos < i)
				return .(input, startPos, i - startPos);

			return default;
		}

		static StringView? ParseQuotes(StringView input, ref int i)
		{
			// @TODO(fusion) - how to handle when quote is not in pair currently this is ignored

			bool isPair = false;
			var startPos = i;
			
			while (i < input.Length)
			{
				i++;

				if (input[i] == QUOTE_CHAR && input[i-1] != '\\')
				{
					isPair = true;
					i++;
					break;
				}
			}

			if (startPos < i)
			{
				if (isPair)
				{
					startPos++;
					return .(input, startPos, i - 1 - startPos);
				}
				
				return .(input, startPos, i - startPos);
			}
				
			return default;
		}

		public static bool Tokenize(StringView input, ref int i, ref int start, List<StringView> tokens)
		{
			tokens.Clear();

			while (i < input.Length)
			{
				SkipWhitespace(input, ref i);
				if (i < input.Length)
				{
					if (tokens.IsEmpty) 
						start = i;
					
					if (input[i] == SEPARATOR_CHAR && !tokens.IsEmpty)
						break;

					StringView? token;
					if (input[i] == '"')
						token = ParseQuotes(input, ref i);
					else
						token = ParseNormal(input, ref i);

					if (token.HasValue)
						tokens.Add(token.Value);
					else
						i++;
				}
			}

			

			return !tokens.IsEmpty;
		}
	}
}
