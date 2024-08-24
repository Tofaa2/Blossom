package engine

import "../ecs"

GameState :: struct {
    settings: GameSettings,
    player: ecs.Entity,
    world: ecs.Entity,
    scene: ecs.Entity,
    ecs_context: ecs.Context,
    request_exit: bool,
}