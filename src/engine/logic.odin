package engine


import rl "vendor:raylib"
import "../utils/logger"
import "../ecs"

// represents game ticking and drawing procedures

tick :: proc(state: ^GameState) {

}

process_input :: proc(state: ^GameState) {


}

render :: proc(state: ^GameState) {
    state.request_exit = rl.WindowShouldClose()
    ctx := &state.ecs_context
    rl.BeginDrawing()
    rl.ClearBackground(rl.RAYWHITE)
    
    draw_performance_debug(10, 10)

    //Button rendering
    {
        buttons := scene_get_all_buttons(ecs.get_component(ctx, state.scene, Scene))
        for button in buttons {
            b := ecs.get_component(ctx, button, Button)
            color := rl.GREEN
            if (is_mouse_on_button(b)) {
                color = rl.RED
                if (ecs.has_component(ctx, button, ButtonClickAction)) {
                    bca := ecs.get_component(ctx, button, ButtonClickAction)
                    if rl.IsMouseButtonPressed(.LEFT) {
                        bca^(b, rl.GetMouseX(), rl.GetMouseY(), .LEFT)
                    }
                    else if rl.IsMouseButtonPressed(.RIGHT) {
                        bca^(b, rl.GetMouseX(), rl.GetMouseY(), .RIGHT)
                    }
                    else if rl.IsMouseButtonPressed(.MIDDLE) {
                        bca^(b, rl.GetMouseX(), rl.GetMouseY(), .MIDDLE)
                    }
                }
            }
            draw_rect(b.x, b.y, b.width, b.height, color)
            if ecs.has_component(ctx, button, ButtonLabel) {
                bl := ecs.get_component(ctx, button, ButtonLabel)
                draw_button_label(b, bl)
            }
        }
    }
    
    rl.EndDrawing()
}

initialize :: proc(settings: ScreenSettings) {
    flags : rl.ConfigFlags = {}
    if (settings.vsync) {
        flags += {.VSYNC_HINT}
    }
    if (settings.fullscreen) {
        flags += {.FULLSCREEN_MODE}
    }
    flags += {.WINDOW_RESIZABLE}
    rl.SetConfigFlags(flags)

    rl.InitWindow(i32(settings.width), i32(settings.height), "Blossom")

    rl.SetTargetFPS(i32(settings.max_fps))
    rl.EnableCursor()
}

shutdown :: proc() {
    rl.CloseWindow()
    // TODO: Free all resources
}