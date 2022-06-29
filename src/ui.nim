import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import options
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]


func `or`(x: ImGuiWindowFlags, y: ImGuiWindowFlags): ImGuiWindowFlags =
    (x.int32 or y.int32).ImGuiWindowFlags

proc drawMenuBar(state: State) =
    if igBeginMainMenuBar():

        if igBeginMenu("File"):

            if igMenuItem("Exit", "CTRL+Q"):
                state.window.setWindowShouldClose(true)

            igEndMenu()

        igEndMainMenuBar()
            

proc drawUI(state: State) =
    let mainViewport = igGetMainViewport()
    igSetNextWindowSize(mainViewport.workSize)
    igSetNextWindowPos(mainViewport.workPos)

    var p_open = false
    igBegin(cstring("fullscreen"), p_open.addr, ImGuiWindowFlags.NoDecoration or
        ImGuiWindowFlags.NoMove or ImGuiWindowFlags.NoSavedSettings)

    drawMenuBar(state)

    igEnd() # fullscreen window

proc uiLoop*(state: State) =
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