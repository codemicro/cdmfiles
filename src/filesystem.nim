import std/[os, strutils]

type
    DirEntry* = ref object
        name*: string
        entryType*: PathComponent
        fullPath*: string

proc getDirectoryContents*(directory: string): seq[DirEntry] =
    # TODO: Cache and sort this
    for (kind, path) in walkDir(directory, relative=false):
        let pathComponents = path.rsplit(DirSep, maxsplit=1)
        result.add(DirEntry(
            name: pathComponents[pathComponents.len - 1],
            entryType: kind,
            fullPath: path,
        ))