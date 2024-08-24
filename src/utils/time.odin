package utils

import "core:time"

current_time_millis :: proc() -> i64 {
    return time.now()._nsec * 1e+6
}
