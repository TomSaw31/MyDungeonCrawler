extends Room
class_name Corridor
## TODO
## A corridor is a special room that is narrower


const FLOOR_SCENE: PackedScene = preload("res://Assets/RoomDecorations/Floor.tscn")
const WALL_SCENE: PackedScene = preload("res://Assets/RoomDecorations/WallL1.tscn")
const CORRIDOR_CORNER_SCENE: PackedScene = preload("res://Assets/RoomDecorations/CorridorCornerWallL1.tscn")

func _ready() -> void:
	spawn_floor([FLOOR_SCENE])
	spawn_corridors([WALL_SCENE],[CORRIDOR_CORNER_SCENE])
