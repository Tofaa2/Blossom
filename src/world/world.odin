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
    blocks: [CHUNK_SIZE * CHUNK_SIZE * CHUNK_DEPTH]BlockType
}

chunk_create_random :: proc(x: i32, z: i32) -> ^Chunk {
    using raylib

    chunk := new(Chunk, context.allocator)
    chunk.x = x
    chunk.z = z
    chunk.world_pos = chunk_pos_to_mat(chunk)

    for nx in 0..<CHUNK_SIZE {
        for nz in 0..<CHUNK_SIZE {

            height := n.noise_2d(SEED, n.Vec2 {
                f64(x * CHUNK_SIZE + nx) / 64.0,
                f64(z * CHUNK_SIZE + nz) / 64.0
            }) * f32(CHUNK_DEPTH / 2) + f32(CHUNK_DEPTH / 2)
    

            for y in 0..<CHUNK_DEPTH {
                if (f32(y) < height ){
                    chunk.blocks[chunk_get_block_index(nx, y, nz)] = .STONE
                }
            }
        }
    }
    
    return chunk
}

chunk_get_block_index :: proc(h: i32, v: i32, d: i32) -> i32 {
    return (d * (CHUNK_SIZE * CHUNK_SIZE)) + (v * CHUNK_SIZE) + h
} 

chunk_get_face_count :: proc(chunk: ^Chunk) -> i32 {
    count : i32 = 0
    for d in 0..<CHUNK_DEPTH {
        for v in 0..<CHUNK_SIZE {
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

chunk_block_is_solid :: proc(chunk: ^Chunk, h: i32, v: i32, d: i32) -> bool {
    if h < 0 {
        return false
    }
    if h >= CHUNK_SIZE {
        return false
    }
    if v < 0 {
        return false
    }
    if v >= CHUNK_SIZE {
        return false
    }
    if d < 0 {
        return false
    }
    if d >= CHUNK_DEPTH {
        return false
    }
    
    return chunk.blocks[chunk_get_block_index(h, v, d)] != .AIR
}