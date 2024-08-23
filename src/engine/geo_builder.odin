package engine

import "../world"
import "core:c"
import "vendor:raylib"

BLOCK_COLORS: []raylib.Rectangle = {
	{0, 0, 0.25, 1},
	{0.25, 0, 0.5, 1},
	{0.5, 0, 0.75, 1},
	{0.75, 0, 1, 1},
	{0.75, 0, 1, 1},
	{0.25, 0, 0.5, 1},
	{0.5, 0, 0.75, 1},
	{0.75, 0, 1, 1},
	{0.75, 0, 1, 1},
	
}

CubeGeometryBuilder :: struct {
	mesh:          ^raylib.Mesh,
	triangleIndex: i32,
	vertIndex:     i32,
	normal:        raylib.Vector3,
	vertColor:     raylib.Color,
	uv:            raylib.Vector2,
}



geo_mesh_chunk :: proc(chunk: ^world.Chunk) -> raylib.Mesh {
	mesh := raylib.Mesh{}
	builder := CubeGeometryBuilder{}
	builder.mesh = &mesh
	geo_allocate(&builder, world.chunk_get_face_count(chunk))

	count: i32 = 0
	for d in 0 ..< world.CHUNK_DEPTH {
		for v in 0 ..< world.CHUNK_SIZE {
			for h in 0 ..< world.CHUNK_SIZE {
				if !world.chunk_block_is_solid(chunk, h, v, d) {
					continue
				}
				faces: [6]bool = {false, false, false, false, false, false}
				if (!world.chunk_block_is_solid(chunk, h - 1, v, d)) {
					faces[world.BlockFace.EAST] = true
				}


				if (!world.chunk_block_is_solid(chunk, h + 1, v, d)) {
					faces[world.BlockFace.WEST] = true
				}

				if (!world.chunk_block_is_solid(chunk, h, v - 1, d)) {
					faces[world.BlockFace.NORTH] = true

				}

				if (!world.chunk_block_is_solid(chunk, h, v + 1, d)) {
					faces[world.BlockFace.SOUTH] = true
				}
				if (!world.chunk_block_is_solid(chunk, h, v, d + 1)) {
					faces[world.BlockFace.UP] = true
				}

				if (!world.chunk_block_is_solid(chunk, h, v, d - 1)) {
					faces[world.BlockFace.DOWN] = true
				}
				vec := raylib.Vector3{f32(h), f32(d), f32(v)}
				geo_add_cube(
					&builder,
					&vec,
					faces,
					chunk.blocks[world.chunk_get_block_index(h, v, d)],
				)

			}
		}
	}

    raylib.UploadMesh(&mesh, false)
    return mesh
}

geo_allocate :: proc(builder: ^CubeGeometryBuilder, triangles: i32) {
	builder.mesh.vertexCount = triangles * 6
	builder.mesh.triangleCount = triangles * 2

	builder.mesh.vertices =
	cast(^f32)(raylib.MemAlloc(u32(size_of(f32) * 3 * builder.mesh.vertexCount)))
	builder.mesh.normals =
	cast(^f32)(raylib.MemAlloc(u32(size_of(f32) * 3 * builder.mesh.vertexCount)))
	builder.mesh.texcoords =
	cast(^f32)(raylib.MemAlloc(u32(size_of(f32) * 2 * builder.mesh.vertexCount)))
	builder.mesh.colors = nil
}

geo_set_normal :: proc(builder: ^CubeGeometryBuilder, normal: raylib.Vector3) {
	builder.normal = normal
}

geo_set_uv :: proc(builder: ^CubeGeometryBuilder, uv: raylib.Vector2) {
	builder.uv = uv
}

geo_push_vertex :: proc(
	builder: ^CubeGeometryBuilder,
	vertex: ^raylib.Vector3,
	xOffset: f32 = 0,
	yOffset: f32 = 0,
	zOffset: f32 = 0,
) {
	index: i32 = 0

	if builder.mesh.colors != nil {
		index = builder.triangleIndex * 12 + builder.vertIndex * 4
		builder.mesh.colors[index] = builder.vertColor.r
		builder.mesh.colors[index + 1] = builder.vertColor.g
		builder.mesh.colors[index + 2] = builder.vertColor.b
		builder.mesh.colors[index + 3] = builder.vertColor.a
	}

	if builder.mesh.texcoords != nil {
		index = builder.triangleIndex * 6 + builder.vertIndex * 2
		builder.mesh.texcoords[index] = builder.uv.x
		builder.mesh.texcoords[index + 1] = builder.uv.y
	}

	if builder.mesh.normals != nil {
		index = builder.triangleIndex * 9 + builder.vertIndex * 3
		builder.mesh.normals[index] = builder.normal.x
		builder.mesh.normals[index + 1] = builder.normal.y
		builder.mesh.normals[index + 2] = builder.normal.z
	}

	index = builder.triangleIndex * 9 + builder.vertIndex * 3
	builder.mesh.vertices[index] = vertex.x + xOffset
	builder.mesh.vertices[index + 1] = vertex.y + yOffset
	builder.mesh.vertices[index + 2] = vertex.z + zOffset

	builder.vertIndex += 1
	if (builder.vertIndex > 2) {
		builder.triangleIndex += 1
		builder.vertIndex = 0
	}

}

geo_add_cube :: proc(
	builder: ^CubeGeometryBuilder,
	position: ^raylib.Vector3,
	faces: [6]bool,
	block: world.BlockType,
) {
	uvRect := BLOCK_COLORS[block]
	geo_set_uv(builder, {0, 0})

	if faces[world.BlockFace.NORTH] {
		geo_set_normal(builder, {0, 0, -1})
		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 0)
		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 0, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 1, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 0)
	}

	// z+
	if (faces[world.BlockFace.SOUTH]) {
		geo_set_normal(builder, {0, 0, 1})

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 1)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 1)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 1, 1)
	}

	// x+
	if (faces[world.BlockFace.WEST]) {
		geo_set_normal(builder, {1, 0, 0})
		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 1, 0, 1)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 1, 0, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 1, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 1, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 1, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 1)
	}

	// x-
	if (faces[world.BlockFace.EAST]) {
		geo_set_normal(builder, {-1, 0, 0})

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 0, 1, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 0, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 0, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 0, 1, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 0, 1, 0)
	}

	if (faces[world.BlockFace.UP]) {
		geo_set_normal(builder, {0, 1, 0})

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 1, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 1, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 1, 0)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 1, 1)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 1, 1)
	}

	geo_set_uv(builder, {0, 0})
	if (faces[world.BlockFace.DOWN]) {
		geo_set_normal(builder, {0, -1, 0})

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 0, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.y})
		geo_push_vertex(builder, position, 1, 0, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 0, 1)

		geo_set_uv(builder, {uvRect.x, uvRect.y})
		geo_push_vertex(builder, position, 0, 0, 0)

		geo_set_uv(builder, {uvRect.width, uvRect.height})
		geo_push_vertex(builder, position, 1, 0, 1)

		geo_set_uv(builder, {uvRect.x, uvRect.height})
		geo_push_vertex(builder, position, 0, 0, 1)
	}

}
