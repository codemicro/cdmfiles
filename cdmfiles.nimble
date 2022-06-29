# Package

version       = "0.1.0"
author        = "AKP"
description   = "A file manager for Linux"
license       = "MIT"
srcDir        = "src"

bin           = @["cdmfiles"]
backend       = "cpp"


# Dependencies

requires "nim >= 1.6.6"
requires "nimgl >= 1.0.0"
requires "https://github.com/nimgl/imgui.git == 1.84.2"
