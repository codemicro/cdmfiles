import std/parseopt
import nimgl/[glfw, imgui]
import os

const
    MaxPathInputLength* = 256

type
    ProgramOptions* = object
        startPath*: string
        showDemo*: bool

    State* = ref object
        opts*: ProgramOptions
        window*: GLFWWindow
        igContext*: ptr ImGuiContext
        currentPath*: string
        
        mainFont*: ptr ImFont
        largeFont*: ptr ImFont

        pathInputText*: cstring

func allocateCstringBuffer(length: int, initialContent: string = ""): cstring =
    var b = newString(length)
    b[0..initialContent.high] = initialContent
    return cstring(b)

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

proc init*(state: var State) =
    if state.opts.startPath == "":
        state.currentPath = getHomeDir()
    else:
        state.currentPath = state.opts.startPath

    state.pathInputText = allocateCstringBuffer(MaxPathInputLength, state.currentPath)
