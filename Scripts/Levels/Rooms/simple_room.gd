extends Room
class_name SimpleRoom
## TODO
const DOOR_SCENE: PackedScene = preload("res://Assets/RoomDecorations/DoorL1.tscn")
const WALL_SCENE: PackedScene = preload("res://Assets/RoomDecorations/WallL1.tscn")
const FLOOR_SCENE: PackedScene = preload("res://Assets/RoomDecorations/Floor.tscn")
const COLUMN_SCENE: PackedScene = preload("res://Assets/RoomDecorations/QuarterColumn.tscn")

func _ready():
	spawn_floor([FLOOR_SCENE])
	spawn_walls_doors([WALL_SCENE],[DOOR_SCENE])
	spawn_columns([COLUMN_SCENE])

