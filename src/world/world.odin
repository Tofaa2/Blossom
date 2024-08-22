package world

import "vendor:raylib"
import "core:os"
import "core:time"
import n "core:math/noise"

SEED :  i64 = time.now()._nsec


CHUNK_DEPTH: i32 : 256
LOWEST_CHUNK_DEPTH: i32 : -64
CHUNK_SIZE: i32 : 16

World :: struct {
    chunks: [dynamic]^Chunk
}

Chunk :: struct {
    x: i32,
    z: i32,
    world_pos: raylib.Matrix,
    world_pos_vec: raylib.Vector3,
    blocks: [CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH]BlockType
}

chunk_create_random :: proc(x: i32, z: i32) -> ^Chunk {
    using raylib

    chunk := new(Chunk, context.allocator)
    chunk.x = x
    chunk.z = z
    chunk.world_pos = chunk_pos_to_mat(chunk)
    chunk.world_pos_vec = raylib.Vector3 { f32(x * CHUNK_SIZE), 0, f32(z * CHUNK_SIZE) }

    for nx in 0..<CHUNK_SIZE {
        for nz in 0..<CHUNK_SIZE {
            amplitude := f32(10)

            height := n.noise_2d(SEED, n.Vec2 {
                f64(x * CHUNK_SIZE + nx) / 64.0,
                f64(z * CHUNK_SIZE + nz) / 64.0
            }) * amplitude + f32(CHUNK_DEPTH / 2)


            for y in 0..<i32(height) {
                chunk.blocks[chunk_get_block_index(nx, y, nz)] = .STONE
            }
        }
    }

    return chunk
}


chunk_get_block_index :: proc(x: i32, y: i32, z: i32) -> i32 {
    return (z * (CHUNK_SIZE * CHUNK_DEPTH)) + (y * CHUNK_SIZE) + x
}

chunk_get_face_count :: proc(chunk: ^Chunk) -> i32 {
    count : i32 = 0
    for d in 0..<CHUNK_SIZE {
        for v in 0..<CHUNK_DEPTH {
            for h in 0..<CHUNK_SIZE {
                if (!chunk_block_is_solid(chunk, h,v,d)) {
                    continue;
                }
                if (!chunk_block_is_solid(chunk, h + 1, v, d)) {
                    count+=1;
                }

                if (!chunk_block_is_solid(chunk, h - 1, v, d)) {
                    count+=1;
                }

                if (!chunk_block_is_solid(chunk, h, v + 1, d)) {
                    count+=1;
                }

                if (!chunk_block_is_solid(chunk, h, v - 1, d)) {
                    count+=1;
                }

                if (!chunk_block_is_solid(chunk, h, v, d + 1)) {
                    count+=1;
                }

                if (!chunk_block_is_solid(chunk, h, v, d - 1)) {
                    count+=1;
                }
            }
        }
    }
    return count
}

chunk_pos_to_mat :: proc(chunk: ^Chunk) -> raylib.Matrix {
    return raylib.MatrixTranslate(f32(chunk.x * CHUNK_SIZE), 0, f32(chunk.z * CHUNK_SIZE))
}

chunk_block_is_solid :: proc(chunk: ^Chunk, x: i32, y: i32, z: i32) -> bool {
    if x < 0 {
        return false
    }
    if x >= CHUNK_SIZE {
        return false
    }
    if y < 0 {
        return false
    }
    if y >= CHUNK_DEPTH {
        return false
    }
    if z < 0 {
        return false
    }
    if z >= CHUNK_SIZE {
        return false
    }

    return chunk.blocks[chunk_get_block_index(x, y, z)] != .AIR
}