package engine

import "vendor:raylib"

Button :: struct {
    x: i32,
    y: i32,
    width: i32,
    height: i32,
}

ButtonLabel :: distinct string
ButtonImage :: distinct raylib.Texture2D
ButtonClickAction :: distinct proc(
    button: ^Button,
    mouseX: i32,
    mouseY: i32,
    mouse: raylib.MouseButton
)

is_on_button :: proc(button: ^Button, x: i32, y: i32) -> bool {
    return x >= button.x && x <= button.x + button.width &&
        y >= button.y && y <= button.y + button.height
}

is_mouse_on_button :: proc(button: ^Button) -> bool {
    pos := raylib.GetMousePosition()
    return is_on_button(button, i32(pos.x), i32(pos.y))
}

