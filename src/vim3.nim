import nimgl/glfw
import common
from core import nil
from paravim import nil

var game = Game()

proc keyCallback(window: GLFWWindow, key: int32, scancode: int32, action: int32, mods: int32) {.cdecl.} =
  paravim.keyCallback(window, key, scancode, action, mods)

proc charCallback(window: GLFWWindow, codepoint: uint32) {.cdecl.} =
  paravim.charCallback(window, codepoint)

proc mouseButtonCallback(window: GLFWWindow, button: int32, action: int32, mods: int32) {.cdecl.} =
  paravim.mouseButtonCallback(window, button, action, mods)

proc cursorPosCallback(window: GLFWWindow, xpos: float64, ypos: float64) {.cdecl.} =
  paravim.cursorPosCallback(window, xpos, ypos)
  game.mouseX = xpos
  game.mouseY = ypos

proc frameSizeCallback(window: GLFWWindow, width: int32, height: int32) {.cdecl.} =
  game.frameWidth = width
  game.frameHeight = height

when isMainModule:
  doAssert glfwInit()

  glfwWindowHint(GLFWContextVersionMajor, 4)
  glfwWindowHint(GLFWContextVersionMinor, 1)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE) # Used for Mac
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)

  let w: GLFWWindow = glfwCreateWindow(1024, 768, "Vim Cubed - You can begin by typing `:e path/to/myfile.txt`")
  if w == nil:
    quit(-1)

  w.makeContextCurrent()
  glfwSwapInterval(1)

  discard w.setKeyCallback(keyCallback)
  discard w.setCharCallback(charCallback)
  discard w.setMouseButtonCallback(mouseButtonCallback)
  discard w.setCursorPosCallback(cursorPosCallback)
  discard w.setFramebufferSizeCallback(frameSizeCallback)

  var width, height: int32
  w.getFramebufferSize(width.addr, height.addr)
  w.frameSizeCallback(width, height)

  paravim.init(game, w)
  core.init(game)

  game.totalTime = glfwGetTime()

  while not w.windowShouldClose:
    let ts = glfwGetTime()
    game.deltaTime = ts - game.totalTime
    game.totalTime = ts
    core.tick(game)
    w.swapBuffers()
    glfwPollEvents()

  w.destroyWindow()
  glfwTerminate()