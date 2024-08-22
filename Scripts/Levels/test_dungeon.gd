extends Node3D
## TODO
const MIN_ROOMS_LEFT_WING = 7
const MAX_ROOMS_LEFT_WING = 12
const MAX_ROOMS_ENTRANCE = 5
var s_location: Vector2i
var main_room_center: Vector2i

const SIMPLE_ROOM_SCENE: PackedScene = preload("res://Assets/Rooms/TestTemple/SimpleRoom/SimpleRoom.tscn")
const MAIN_ROOM_SCENE: PackedScene = preload("res://Assets/Rooms/TestTemple/MainRoom/MainRoom.tscn")
const CORRIDOR_ROOM_SCENE: PackedScene = preload("res://Assets/Rooms/TestTemple/Corridor/Corridor.tscn")

# ROOM TYPE
const SIMPLE_ROOM = 0
const SPAWN_ROOM = 1
const CORRIDOR = 2
const MAIN_ROOM = 3
const MAIN_ROOM_CENTER = 4
const MAIN_ORTHOGONAL_ROOM = 5
const GHOST_ROOM_TYPE = [MAIN_ROOM]

# DUNGEON AREAS
const ENTRANCE_AREA = 0
const MAIN_ROOM_AREA = 1
const LEFT_WING_AREA = 2


var map_rooms = {}
var map_areas = {}
var entrance_rooms = []
var left_wing_rooms = []

func _ready():
	_generate_dungeon()
	_show_dungeon()
	_spawn_rooms()

func _generate_dungeon():
	_generate_spawn()
	_generate_entrance()
	_generate_main_room()
	_generate_left_wing()

func _generate_spawn():
	s_location = Vector2i(0,0)
	map_rooms[Vector2i(0,0)] = SPAWN_ROOM
	map_areas[Vector2i(0,0)] = ENTRANCE_AREA

func _generate_entrance():
	var rooms = randi_range(0,MAX_ROOMS_ENTRANCE)
	s_location = Vector2i(0,-1)
	map_rooms[s_location] = CORRIDOR
	map_areas[s_location] = ENTRANCE_AREA
	while rooms != 0:
		var x: int = randi_range(1,3)
		if x == 1:
			s_location += Vector2i(0,-1)
		if x == 2:
			s_location += Vector2i(-1,0)
		if x == 3:
			s_location += Vector2i(1,0)
		if not s_location in map_rooms.keys():
			entrance_rooms.append(s_location)
			map_rooms[s_location] = SIMPLE_ROOM
			map_areas[s_location] = ENTRANCE_AREA
			rooms -= 1
	_generate_random_corridors(entrance_rooms)

func _generate_main_room():
	s_location += Vector2i(0,-2)
	for i in range(-1,2):
		for j in range(-1,2):
			if i in [-1,1] and j in [-1,1]:
				map_rooms[s_location + Vector2i(i,j)] = MAIN_ROOM
			else:
				map_rooms[s_location + Vector2i(i,j)] = MAIN_ORTHOGONAL_ROOM
			map_areas[s_location + Vector2i(i,j)] = MAIN_ROOM_AREA
	map_areas[s_location] = MAIN_ROOM_AREA
	map_rooms[s_location] = MAIN_ROOM_CENTER
	main_room_center = s_location

func _generate_left_wing():
	var rooms = randi_range(MIN_ROOMS_LEFT_WING,MAX_ROOMS_LEFT_WING)
	s_location = main_room_center + Vector2i(-2,0)
	map_rooms[s_location] = CORRIDOR
	map_areas[s_location] = LEFT_WING_AREA
	var repetition: Vector2i = Vector2i.ZERO
	while rooms != 0:
		var x: int = randi_range(1,4)
		while repetition.y > 2 and repetition.x == x:
			x = randi_range(1,4)
		if repetition.x != x:
			repetition.x = x
			repetition.y = 1
		else:
			repetition.y += 1
		if x == 1:
			s_location += Vector2i(0,-1)
		if x == 2:
			s_location += Vector2i(0,1)
		if x == 3:
			s_location += Vector2i(-1,0)
		if x == 4 and rooms < rooms/2:
			s_location += Vector2i(1,0)
		if not s_location in map_rooms.keys():
			left_wing_rooms.append(s_location)
			map_rooms[s_location] = SIMPLE_ROOM
			map_areas[s_location] = LEFT_WING_AREA
			rooms -= 1
	_generate_random_corridors(left_wing_rooms)

func _generate_random_corridors(r_positions: Array):
	for r_position in r_positions:
		if _calculate_number_rooms_next_to(r_position) > 1 and _calculate_number_corridors_next_to(r_position) < 2:
			if randf() > 0.25:
				map_rooms[r_position] = CORRIDOR
	var rep = 0
	for r_position in r_positions:
		if map_rooms[r_position] == CORRIDOR:
			rep += 1
		else:
			rep = 1
		if rep > 2:
			map_rooms[r_position] = SIMPLE_ROOM

func _calculate_number_rooms_next_to(r_position: Vector2i) -> int:
	'''Return the number of rooms next to the position'''
	var res: int = 0
	for room in _get_adjacent_rooms(r_position):
		if room != null and not map_rooms[room] in GHOST_ROOM_TYPE:
			res += 1
	return res

func _calculate_number_corridors_next_to(r_position: Vector2i) -> int:
	'''Return the number of corridors next to the position'''
	var res: int = 0
	for room in _get_adjacent_rooms(r_position):
		if room != null:
			if map_rooms[room] == CORRIDOR:
				res += 1
	return res

func _show_dungeon():
	print("ROOM TYPES")
	for i in range(-10,10):
		var chaine: String = ""
		for j in range(-10,10):
			if Vector2i(j,i) in map_rooms.keys():
				chaine += str(map_rooms[Vector2i(j,i)])
			else:
				chaine += " "
		print(chaine)
	print("DUNGEON AREAS")
	for i in range(-10,10):
		var chaine: String = ""
		for j in range(-10,10):
			if Vector2i(j,i) in map_areas.keys():
				chaine += str(map_areas[Vector2i(j,i)])
			else:
				chaine += " "
		print(chaine)

func _spawn_rooms():
	for key in map_rooms.keys():
		var scene: Room = _get_room_scene(key)
		if scene != null:
			scene.position = Vector3(key.x * 36,0 , key.y * 36)
			scene.doors = _calculate_room_type(key)
			get_tree().root.add_child.call_deferred(scene)

func _calculate_room_type(pos: Vector2i) -> String:
	var res: String = ""
	if pos != main_room_center:
		var adj: Array = _get_adjacent_rooms(pos)
		for i in range(4):
			if adj[i] == null or (map_areas[adj[i]] != map_areas[pos] and map_rooms[adj[i]] != MAIN_ORTHOGONAL_ROOM):
				res += "X"
			elif map_rooms[adj[i]] in GHOST_ROOM_TYPE:
				res += "x"
			else:
				res += str(i+1)
	else:
		if pos + Vector2i(0,-2) in map_rooms.keys():
			res += "1"
		else:
			res += "x"
		if pos + Vector2i(2,0) in map_rooms.keys():
			res += "2"
		else:
			res += "x"
		if pos + Vector2i(0,2) in map_rooms.keys():
			res += "3"
		else:
			res += "x"
		if pos + Vector2i(-2,0) in map_rooms.keys():
			res += "4"
		else:
			res += "x"
	return res
	
func _get_room_scene(pos: Vector2i) -> Node3D:
	var scene: Node3D = null
	if map_rooms[pos] == SPAWN_ROOM:
		scene = SIMPLE_ROOM_SCENE.instantiate()
	elif map_rooms[pos] == SIMPLE_ROOM:
		scene = SIMPLE_ROOM_SCENE.instantiate()
	elif map_rooms[pos] == CORRIDOR:
		scene = CORRIDOR_ROOM_SCENE.instantiate()
	elif map_rooms[pos] == MAIN_ROOM_CENTER:
		scene = MAIN_ROOM_SCENE.instantiate()
	return scene

func _get_adjacent_rooms(r_pos: Vector2i) -> Array:
	var rooms: Array = []
	if r_pos + Vector2i(0,-1) in map_rooms.keys() and map_rooms[r_pos + Vector2i(0,-1)] not in GHOST_ROOM_TYPE:
		rooms.append(r_pos + Vector2i(0,-1))
	else:
		rooms.append(null)
	if r_pos + Vector2i(1,0) in map_rooms.keys() and map_rooms[r_pos + Vector2i(1,0)] not in GHOST_ROOM_TYPE:
		rooms.append(r_pos + Vector2i(1,0))
	else:
		rooms.append(null)
	if r_pos + Vector2i(0,1) in map_rooms.keys() and map_rooms[r_pos + Vector2i(0,1)] not in GHOST_ROOM_TYPE:
		rooms.append(r_pos + Vector2i(0,1))
	else:
		rooms.append(null)
	if r_pos + Vector2i(-1,0) in map_rooms.keys() and map_rooms[r_pos + Vector2i(-1,0)] not in GHOST_ROOM_TYPE:
		rooms.append(r_pos + Vector2i(-1,0))
	else:
		rooms.append(null)
	return rooms
