package utils

i32_checked :: proc "contextless" (v: $T) -> (out: i32, ok: bool) where intrinsics.type_is_integer(T) {
    when size_of(T) < size_of(out) {
        return i32(v), true
    } else when size_of(T) == size_of(out) {
        return i32(v), !intrinsics.type_is_unsigned(T) || v <= T(max(i32))
    } else {
        return i32(v), T(min(i32)) <= v && v <= T(max(i32))
    }
}