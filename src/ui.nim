import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import std/[strformat, os]
import options, fontawesome, filesystem

const QuickAccessWidth = 200

func `or`[T](x, y: T): T =
    (x.int32 or y.int32).T

proc drawMenuBar(state: State) =
    if igBeginMainMenuBar():

        if igBeginMenu("File"):

            if igMenuItem("Exit", "CTRL+Q"):
                state.window.setWindowShouldClose(true)

            igEndMenu()

        igEndMainMenuBar()


proc drawNavigationCollection(state: State) =
    let buttonSize = ImVec2(x: igGetFontSize() + float32(state.igContext.style.framePadding.y * 2))

    discard igButton(IconFAArrowLeft, buttonSize)
    igSameLine()
    discard igButton(IconFAArrowRight, buttonSize)
    igSameLine()
    discard igButton(IconFAArrowUp, buttonSize)

    igSameLine()
    igSetNextItemWidth(-state.igContext.style.framePadding.y)
    igInputText("", state.pathInputText, MaxPathInputLength)

proc drawFileTree(state: State, directory: string) =
    let nodeOpts = ImGuiTreeNodeFlags.Leaf or ImGuiTreeNodeFlags.OpenOnArrow or ImGuiTreeNodeFlags.SpanAvailWidth or ImGuiTreeNodeFlags.Leaf or ImGuiTreeNodeFlags.NoTreePushOnOpen

    var textBaseSize: ImVec2
    igCalcTextSizeNonUDT(textBaseSize.addr, cstring("A"))
    let textBaseWidth = textBaseSize.x

    if igBeginTable("File tree", 3, ImGuiTableFlags.BordersV or ImGuiTableFlags.BordersOuterH or ImGuiTableFlags.Resizable or ImGuiTableFlags.RowBg or ImGuiTableFlags.NoBordersInBody):
        igTableSetupColumn("Name", ImGuiTableColumnFlags.NoHide)
        igTableSetupColumn("Size", ImGuiTableColumnFlags.WidthFixed, textBaseWidth * 12f32)
        igTableSetupColumn("Type", ImGuiTableColumnFlags.WidthFixed, textBaseWidth * 18f32)
        igTableHeadersRow()

        for (i, dirEntry) in getDirectoryContents(directory).pairs:
            igTableNextRow()
            igTableNextColumn()
            igTreeNodeEx(i.unsafeAddr, nodeOpts or ImGuiTreeNodeFlags.SpanFullWidth, cstring(dirEntry.name))
            igTableNextColumn()
            igTextDisabled(cstring("--"))
            igTableNextColumn()
            igTextUnformatted(cstring(dirEntry.entryType.repr))

        igEndTable()


proc drawQuickAccessPanel(state: State) =
    igBeginGroup()
    
    igText("quick access goes here")

    igEndGroup()

proc drawMainPanel(state: State) =
    igBeginGroup()

    drawFileTree(state, state.currentPath)

    igEndGroup()

proc drawUI(state: State) =
    let mainViewport = igGetMainViewport()
    igSetNextWindowSize(mainViewport.workSize)
    igSetNextWindowPos(mainViewport.workPos)

    var p_open = false
    igBegin(cstring("fullscreen"), p_open.addr, ImGuiWindowFlags.NoDecoration or
        ImGuiWindowFlags.NoMove or ImGuiWindowFlags.NoSavedSettings)

    drawMenuBar(state)
    drawNavigationCollection(state)

    let initialCursorYPosition = igGetCursorPosY() + 5 # bump down by 5px
    igSetCursorPosY(initialCursorYPosition)

    drawQuickAccessPanel(state)

    igSetCursorPos(ImVec2(
        x: QuickAccessWidth + state.igContext.style.framePadding.x,
        y: initialCursorYposition,
    ))

    drawMainPanel(state)

    igEnd()

# This is hacky, and done I don't think the signature for the functions to add
# fonts in the DearImGui binding is quite right. In essence, this just
# sidesteps the type system.
{.emit: fmt"static const ImWchar glyph_ranges[] = {{ {IconMinFA}, {IconMaxFA}, 0 }};".}
var 
    glyphRanges {.importc: "glyph_ranges", nodecl.}: ptr ImWchar16
    maxFloat {.importc: "FLT_MAX", nodecl.}: float32 # this feels so brittle

proc initUI(state: State) = 
    let io = igGetIO()

    const fontSize = 16

    # TODO: Not this font
    io.fonts.addFontFromFileTTF("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", fontSize)

    var config = ImFontConfig(
        mergeMode: true,
        glyphMinAdvanceX: fontSize - 1,

        fontDataOwnedByAtlas: true,
        oversampleH: 3,
        oversampleV: 1,
        glyphMaxAdvanceX: maxFloat,
        rasterizerMultiply: 1,
        ellipsisChar: ImWchar(0) - 1
    )

    io.fonts.addFontFromMemoryCompressedTTF(faData, faDataSize, fontSize - 1, config.addr, glyphRanges)

proc runUI*(state: State) =
    initUI(state)

    while not state.window.windowShouldClose:
        glfwPollEvents()

        igOpenGL3NewFrame()
        igGlfwNewFrame()
        igNewFrame()

        if state.opts.showDemo:
            igShowDemoWindow(state.opts.showDemo.addr)
        else:
            state.drawUI()

        igRender()

        glClearColor(0.45f, 0.55f, 0.60f, 1.00f)
        glClear(GL_COLOR_BUFFER_BIT)

        igOpenGL3RenderDrawData(igGetDrawData())

        state.window.swapBuffers()
