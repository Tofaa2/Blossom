package main

import "core:fmt"
import "vendor:raylib"
import "vendor:raylib/rlgl"
import "world"
import "engine"
import "ecs"
import "core:time"
import "core:mem"

GameState :: struct {
	camera: raylib.Camera3D,
	world: ^world.World,
}

main :: proc() {
    using raylib

	ctx := ecs.init_ecs();


    InitWindow(1200, 800, "Blossom");
	SetTargetFPS(GetMonitorRefreshRate(GetCurrentMonitor()));
    SetConfigFlags({.FULLSCREEN_MODE, .MSAA_4X_HINT});

	rlgl.EnableBackfaceCulling()

    tileTexture := LoadRenderTexture(64, 16);
	BeginTextureMode(tileTexture);
	ClearBackground(BLANK);
	DrawRectangle(0, 0, 16, 16, DARKBROWN);
	DrawRectangle(16, 0, 16, 16, BROWN);
	DrawRectangle(32, 0, 16, 16, GREEN);
	DrawRectangle(48, 0, 16, 16, GOLD);
	EndTextureMode();

	DisableCursor();

    camera := Camera3D {}
    camera.fovy = 45;
	camera.up.y = 1;
	camera.target.x = 8;
	camera.target.z = 8;
	camera.target.y = 4;

    camera.position.x = 32;
	camera.position.z = 32;
	camera.position.y = 16;

	world_entity := ecs.create_entity(&ctx);
	ecs.add_component(&ctx, world_entity, make([dynamic]world.Chunk, 0, 100))
	ecs.add_component(&ctx, world_entity, make([dynamic]Mesh, 0, 100))

	chunk_data := ecs.get_component(&ctx, world_entity, [dynamic]world.Chunk)
	mesh_data := ecs.get_component(&ctx, world_entity, [dynamic]Mesh)

	for i in 0..<10 {
		for j in 0..<10 {
			chunk := world.chunk_create_random(i32(i), i32(j))
			append(chunk_data, chunk^);

			mesh := engine.geo_mesh_chunk(chunk)
			append(mesh_data, mesh)
		}
	}
	for c in ecs.get_component(&ctx, world_entity, [dynamic]world.Chunk) {}

	// game_world := new(world.World)
	// game_world.chunks = make([dynamic]^world.Chunk, 0, 100)	
	// meshes : [dynamic]Mesh = make([dynamic]Mesh, 0, 100)


    mat := LoadMaterialDefault()
    mat.maps[0].color = WHITE;
	mat.maps[0].texture = tileTexture.texture;
	

	wire_more := false

    for !WindowShouldClose() {
        UpdateCamera(&camera, .FIRST_PERSON)
		if IsKeyDown(.SPACE) {
			camera.position.y += 0.1
		}
		if IsKeyDown(.LEFT_SHIFT) {
			camera.position.y -= 0.1
		}

		if IsKeyPressed(.L) {
			wire_more = !wire_more
		}



		BeginDrawing();
		ClearBackground(SKYBLUE);

		BeginMode3D(camera);
		if (wire_more) {
			rlgl.EnableWireMode()
		}
		for i in 0..<len(mesh_data) {
			mesh := mesh_data[i]
			chunk := chunk_data[i]
			DrawMesh(mesh, mat, chunk.world_pos)
		}
		if (wire_more) {
			rlgl.DisableWireMode()
		}
		EndMode3D();

		DrawFPS(0, 0);
		EndDrawing();

		free_all(context.temp_allocator)
    }

	for mesh in mesh_data {
		UnloadMesh(mesh);		
 	}

	UnloadRenderTexture(tileTexture);
	CloseWindow();
}

