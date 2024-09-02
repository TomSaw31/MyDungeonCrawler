extends Node3D
class_name Room
## TODO

@export var doors: String = "XXXX"
@export var has_floor: bool = true
var walls_positions: Array = [Vector3i(0,0,-18),Vector3i(18,0,0),Vector3i(0,0,18),Vector3i(-18,0,0)]
var corridors_walls_positions: Array = [Vector3i(0,0,-9),Vector3i(9,0,0),Vector3i(0,0,9),Vector3i(-9,0,0)]
var corridors_walls_corner_positions: Array = [Vector3i(9,0,-9),Vector3i(9,0,9),Vector3i(-9,0,9),Vector3i(-9,0,-9)]
var columns_positions: Array = [Vector3i(17,0,-17),Vector3i(17,0,17),Vector3i(-17,0,17),Vector3i(-17,0,-17)]
var main_room_columns_positions: Array = [Vector3(52,0,-52),Vector3(52,0,52),Vector3(-52,0,52),Vector3(-52,0,-52)]


func spawn_floor(floors: Array) -> void:
	if has_floor:
		var scene: Node3D = floors.pick_random().instantiate()
		scene.position = Vector3i.ZERO
		add_child(scene)

func spawn_walls_doors(walls_scenes: Array, doors_scenes: Array) -> void:
	var scene: Node3D
	for i in range(4):
		if doors[i] != "x":
			if doors[i] == "X":
				scene = walls_scenes.pick_random().instantiate()
			else:
				scene = doors_scenes.pick_random().instantiate()
			scene.position = walls_positions[i]
			scene.rotation.y = deg_to_rad(i * 90)
			add_child(scene)

func spawn_columns(columns_scenes: Array) -> void:
	var scene
	for i in range(4):
		scene = columns_scenes.pick_random().instantiate()
		scene.position = columns_positions[i]
		scene.rotation.y = deg_to_rad(180 - i * 90)
		add_child(scene)

func spawn_corridors(walls_scenes: Array, walls_angles: Array) -> void:
	var scene: Node3D
	for i in range(4):
		if doors[i] != "x":
			if doors[i] == "X":
				scene = walls_scenes.pick_random().instantiate()
				scene.position = corridors_walls_positions[i]
				scene.rotation.y = deg_to_rad(i * 90)
				add_child(scene)
	for i in range(4):
		if doors[i].to_lower() != "x" and doors[(i+1)%4].to_lower() != "x":
			scene = walls_angles.pick_random().instantiate()
			scene.position = corridors_walls_corner_positions[i]
			scene.rotation.y = deg_to_rad(90 - i * 90)
			add_child(scene)

func _spawn_main_room_floors(floors_scenes: Array) -> void:
	if has_floor:
		for i in range(-1,2):
			for j in range(-1,2):
				var scene: Node3D = floors_scenes.pick_random().instantiate()
				scene.position = Vector3(i * 36, 0, j * 36)
				scene.rotation.y = deg_to_rad(90 * i)
				add_child(scene)

func _spawn_main_room_walls(walls_scenes: Array, doors_scenes: Array) -> void:
		var scene: Node3D
		for j in range(2):
			for i in range(-1,2):
				if (i == 0 and j == 0 and doors[2] == "3") or (i == 0 and j == 1 and doors[0] == "1"):
					scene = doors_scenes.pick_random().instantiate()
				else:
					scene = walls_scenes.pick_random().instantiate()
				scene.position = Vector3(i * 36, 0, (-1)**j * 53)
				add_child(scene)
		for j in range(2):
			for i in range(-1,2):
				if (i == 0 and j == 0 and doors[1] == "2") or (i == 0 and j == 1 and doors[3] == "4"):
					scene = doors_scenes.pick_random().instantiate()
				else:
					scene = walls_scenes.pick_random().instantiate()
				scene.position = Vector3((-1)**j * 53, 0, i * 36)
				scene.rotation.y = deg_to_rad(90)
				add_child(scene)

func _spawn_main_room_columns(columns_scenes: Array) -> void:
	var scene
	for i in range(4):
		scene = columns_scenes.pick_random().instantiate()
		scene.position = main_room_columns_positions[i]
		scene.rotation.y = deg_to_rad(180 - 90 * i)
		add_child(scene)

## Called when entering the room
func enter_room() -> void:
	pass

## Called when exiting the state
func exit_room() -> void:
	call_deferred("queue_free")

## Called every frame when the state is active
func update(_delta: float) -> void:
	pass

## Called every physics frame when the state is active
func physics_room(_delta: float) -> void:
	pass

## Called when receiving an input and the state is active
func input_room(_event: InputEvent) -> void:
	pass
