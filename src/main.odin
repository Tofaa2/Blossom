package main

import "core:fmt"
import "vendor:raylib"
import "vendor:raylib/rlgl"
import "world"
import "engine"
import "ecs"
import "core:time"
import "core:mem"
import "utils"

FIXED_INTERVAL :: 60.0
FIXED_INTERVAL_NS : f64 : 1_000_000_000 / FIXED_INTERVAL

main :: proc() {
	state := engine.GameState {}
	state.settings = engine.settings_read()
	state.request_exit = false
	state.ecs_context = ecs.init_ecs()

	state.scene = ecs.create_entity(&state.ecs_context)
	ecs.add_component(&state.ecs_context, state.scene, engine.scene_main_menu(&state))
	
	state.world = ecs.create_entity(&state.ecs_context)
	state.player = ecs.create_entity(&state.ecs_context)

	engine.initialize(state.settings.screen)


	draw_interval : f64 = 1000000000 / 60.0
	last_time : f64 = f64(time.now()._nsec)
	current_time : f64 = f64(time.now()._nsec)
	delta : f64 = 0.0

	for !state.request_exit {

		current_time = f64(time.now()._nsec)
		delta = (current_time - last_time) / draw_interval
		last_time = current_time

		if delta > 1.0 {
			engine.tick(&state)
			delta -= 1.0
		}

		engine.render(&state)
		engine.process_input(&state)
		free_all(context.temp_allocator)
	}

	engine.shutdown()
}



main_two :: proc() {
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

