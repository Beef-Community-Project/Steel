# Beef-Extensions-Lib
A library consisting of useful extensions for the Beef core lib types.

Thanks to Beef's extension mechanism it is easy to add method to already defined types such as String, Path, List or other from the Beef corelib.
The goal of this library is to regroup useful extensions that Beef programers might frequently use.

# Contributing
Contributions are welcomed and here are some rules to follow when adding new extensions:

1. Add the extension inside the folder that follows the type's namespace.
    - For example, the String type's namespace is *System* so its extension should live under the System folder. The Path type is under System.IO
so its extension should be located in the folder System.IO.
2. Create new folders following the namespace of the type you are extending.
2. The extension's file must follow the following naming convention TypeExtensions.bf
    - The *String* extensions are inside the **StringExtensions.bf** file, the *Path* extensions inside the **PathExtensions.bf** file.
3. One file per type's extension
    - The *String* extensions lives in the **StringExtensions.bf** file only.
