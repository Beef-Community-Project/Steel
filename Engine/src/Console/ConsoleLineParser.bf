using System;
using System.Collections;

namespace SteelEngine.Console
{
	class ConsoleLineParser
	{
		const char8 SEPARATOR_CHAR = ';';
		const char8 QUOTE_CHAR = '"';
		const char8 COMMENT_CHAR = '#';

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
				if (input[i].IsWhiteSpace || input[i] == SEPARATOR_CHAR || input[i] == COMMENT_CHAR)
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
			// @TODO(fusion) - escaped quotes keep the backslash char, they should be removed

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

					if (input[i] == COMMENT_CHAR)
						break;

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

		// Sets output to contain all tokens and
		// transforms tokens to be relative to output string
		public static bool Tokenize(StringView input, ref int i, ref int start, List<StringView> tokens, String output)
		{
			if (Tokenize(input, ref i, ref start, tokens))
			{
				output.Set(StringView(input, start, i - start));
				for (var t in ref tokens)
				{
					let offset = (t.Ptr - input.Ptr) - start;
					t = .(output, offset, t.Length);
				}
				return true;
			}

			return false;
		}
	}
}
