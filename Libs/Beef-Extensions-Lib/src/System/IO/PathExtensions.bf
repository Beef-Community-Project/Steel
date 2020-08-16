namespace System.IO
{
	extension Path
	{
		public static void Join(StringView pathA, StringView pathB, String outPath)
		{
			if (pathA.IsNull || pathB.IsNull || (outPath == null))
			{
				return;
			}
			outPath.Clear();
			outPath.AppendF("{}{}{}", pathA, Path.DirectorySeparatorChar, pathB);
		}
	}
}
