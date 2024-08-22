extends Room
class_name MainRoom
## TODO

const DOOR_SCENE: PackedScene = preload("res://Assets/RoomDecorations/DoorL3.tscn")
const WALL_SCENE: PackedScene = preload("res://Assets/RoomDecorations/WallL3.tscn")
const FLOOR_SCENE: PackedScene = preload("res://Assets/RoomDecorations/Floor.tscn")
const COLUMN_SCENE: PackedScene = preload("res://Assets/RoomDecorations/QuarterColumn_L3.tscn")

func _ready():
	_spawn_main_room_floors([FLOOR_SCENE])
	_spawn_main_room_walls([WALL_SCENE],[DOOR_SCENE])
	_spawn_main_room_columns([COLUMN_SCENE])



