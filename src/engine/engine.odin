package engine

import rl "vendor:raylib"
import "core:strings"

draw_centered_text :: proc(
    text: string,
    x: i32,
    y: i32,
    width: i32,
    height: i32,
    font_size: i32 = 20,
    color: rl.Color = rl.BLACK
) {
    //DrawText(m_label.c_str(), m_posX - (MeasureText(m_label.c_str(), fontSize) / 2) + (m_width / 2), m_posY - (fontSize / 2) + (m_height / 2), fontSize, BLACK);
    cstring_version := strings.clone_to_cstring(text, context.temp_allocator)
    rl.DrawText(
        cstring_version,
        
        x - (rl.MeasureText(cstring_version, font_size) / 2) + (width / 2),
        y - (font_size / 2) + (height / 2),
        font_size, color
    )
}

draw_button_label :: proc(button: ^Button, label: ^ButtonLabel) {
    draw_centered_text(
        string(label^),
        button.x / 2 + button.width / 2,
        button.y / 2 + button.height * 2,
        button.width, button.height
    )
} 

draw_rect :: proc(x, y, width, height: i32, color: rl.Color = rl.BLACK ) {
    rl.DrawRectangle(x, y, width, height, color)
}


draw_performance_debug :: proc(x: i32, y: i32) {
    rl.DrawText(rl.TextFormat("FPS: %i", rl.GetFPS()), x, y, 20, rl.BLACK)
    rl.DrawText(rl.TextFormat("Frame Time: %f", rl.GetFrameTime()), x, y + 20, 20, rl.BLACK)
    rl.DrawText(rl.TextFormat("Mouse Pos: %i, %i", rl.GetMouseX(), rl.GetMouseY()), x, y + 40, 20, rl.BLACK)
}

// x, y are in the range of 0..1
// returns the scaled resolution according to the window size
scaled_resolution :: proc(x, y:  f16) -> ScaledResolution {
    scren_x := rl.GetScreenWidth()
    screen_y := rl.GetScreenHeight()
    return {f32(x * f16(scren_x)), f32(y * f16(screen_y))}
}

ScaledResolution :: [2]f32