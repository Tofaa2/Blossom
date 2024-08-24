package utils_logger

import "core:fmt"
import "core:time"
import "vendor:raylib"
import "core:c"
import "core:strings"

log :: proc(level: Level = .INFO, message: string) {
    fmt.printf("[%d] %s\n", time.now(), message)
}

log_arged :: proc(level: Level = .INFO, message: string, args: ..any) {
    c_verion := strings.clone_to_cstring(message, context.temp_allocator)
    text := raylib.TextFormat(c_verion, args)
    fmt.printf("[%d] %s\n", time.now(), text)
}

// raylib_log :: #type proc "c" (logLevel: raylib.TraceLogLevel, text: cstring, args: c.va_list) {
//     fmt.printf("[%d] %s\n", time.now(), text)
// }   

Level :: enum {
    INFO,
    WARNING,
    ERROR,
}