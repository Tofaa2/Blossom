package engine

import "vendor:raylib"
import "../ecs"
import "../utils/logger"

Scene :: struct {
    state: ^GameState,
    entities: []ecs.Entity
}

// scene_settings :: proc(state: ^GameState) -> Scene {
//     back_button := ecs.create_entity(&state.ecs_context)
//     ecs.add_component(&state.ecs_context, back_button, Button {
        
//     })
// }

scene_main_menu :: proc(state: ^GameState) -> Scene {
    
    play_button := ecs.create_entity(&state.ecs_context)
    ecs.add_components_2(
        &state.ecs_context,
        play_button,
        Button {
            x = 200,
            y = 200,
            width = 200,
            height = 50
        },
        ButtonLabel("Play")
    )
    
    settings_button := ecs.create_entity(&state.ecs_context)
    ecs.add_components_3(
        &state.ecs_context,
        settings_button, Button {
            x = 200,
            y = 300,
            width = 200,
            height = 50
        },
        ButtonLabel("Settings"),
        ButtonClickAction(proc(button: ^Button, mouseX: i32, mouseY: i32, mouse: raylib.MouseButton) {
            logger.log_arged(.INFO, "Settings button clicked at x: %i, y: %i", mouseX, mouseY)
        })
    )

    return {
        state = state,
        entities = {play_button}
    }
}


scene_get_all_buttons :: proc(scene: ^Scene) -> [dynamic]ecs.Entity {
    if scene == nil {
        return {}
    }
    return ecs.get_entities_with_components(&scene.state.ecs_context, {Button})
}