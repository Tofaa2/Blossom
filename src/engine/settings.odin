package engine

import "core:encoding/json"
import "core:io"
import "core:os"
import "core:path/filepath"
import "core:fmt"

GameSettings :: struct {
    camera: CameraSettings,
    render: RenderSettings,
    screen: ScreenSettings,
}

settings_save :: proc(settings: GameSettings) -> GameSettings {
    
    if json_data, err := json.marshal(settings, allocator = context.temp_allocator); err == nil {
        if !os.write_entire_file("settings", json_data) {
            fmt.println("Couldn't write file!")
        }
    } else {
        fmt.println("Couldn't marshal struct!")
    }
    
    return GameSettings {}
}

settings_read :: proc() -> GameSettings {
    if json_data, ok := os.read_entire_file("settings", context.temp_allocator); ok {
        my_struct: GameSettings
    
        if json.unmarshal(json_data, &my_struct) == nil {
            return my_struct
        } else {
            fmt.println("Failed to unmarshal JSON")
        }
    } else {
        base_settings := GameSettings {
            screen = {
                width = 800,
                height = 600,
                fullscreen = false,
                vsync = true,
                max_fps = 60,
            },
            camera = {
                fovy = 45,
            },
            render = {
                wire_mode = false,
            },
    
        }
        settings_save(base_settings)
        return base_settings
    }
    return {}
}

CameraSettings :: struct {
    fovy: u8,
}

RenderSettings :: struct {
    wire_mode: bool,
}

ScreenSettings :: struct {
    fullscreen: bool,
    vsync: bool,
    max_fps: u16,
    width: u16,
    height: u16,
}