import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]
import nimgl/[opengl, glfw]
import ui, options

const
  InitialWindowWidth = 700
  InitialWindowHeight = 500

proc init(windowTitle: string, width, height: int32): (GLFWWindow,
    ptr ImGuiContext) =
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let window = glfwCreateWindow(width, height, cstring(windowTitle))
  if window == nil:
    stderr.writeLine("could not create window with GLFW")
    quit(1)

  window.makeContextCurrent()

  doAssert glInit()

  let context = igCreateContext()

  doAssert igGlfwInitForOpenGL(window, true)
  doAssert igOpenGL3Init()

  return (window, context)

proc teardown(window: GLFWWindow, context: ptr ImGuiContext) =
  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  window.destroyWindow()
  glfwTerminate()

proc main() =
  var
    opts = loadOptions()
    state: State

  new(state)
  state.opts = opts

  let (window, context) = init("cdmfiles", InitialWindowWidth, InitialWindowHeight)

  state.window = window
  state.init()

  debugEcho(state[])

  uiLoop(state)

  teardown(window, context)


when isMainModule:
  main()
