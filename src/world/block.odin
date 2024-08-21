package world

BlockType :: enum(u8) {
    AIR = 0,
    DARK_DIRT = 1,
    DIRT = 2,
    GRASS = 3,
    GOLD = 4,
    STONE = 5,
    SAND = 6,
    WATER = 7,
}

BlockFace :: enum {
    NORTH,
    SOUTH,
    WEST,
    EAST,
    UP,
    DOWN
}