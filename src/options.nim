import std/parseopt
import nimgl/glfw
import os

type 
    ProgramOptions* = object
        startPath*: string
        showDemo*: bool

    State* = ref object
        opts*: ProgramOptions
        window*: GLFWWindow
        currentPath*: string

proc loadOptions*(): ProgramOptions =
    for kind, key, val in getopt():
        case kind
        of cmdArgument:
            if result.startPath == "":
                result.startPath = key
            else:
                result.startPath = result.startPath & " " & key
        of cmdLongOption, cmdShortOption:
            case key
            of "demo": result.showDemo = true
        of cmdEnd: assert(false) # cannot happen

proc init*(state: var State)=
    if state.opts.startPath == "":
        state.currentPath = getHomeDir()
    else:
        state.currentPath = state.opts.startPath