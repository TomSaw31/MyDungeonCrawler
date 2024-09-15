extends Node3D
## Generate the room layout of the map

const EMPTY = 0
const NORMAL_ROOM = 1
const BOSS_ROOM = 2
const TREASURE_ROOM = 3
const COIN_ROOM = 4
const STARTING_ROOM = 5

const ROOM_SIZE = 36

## The width of the map
var grid_width: int = 15
## The height of the map
var grid_height: int = 15
## The min amount of rooms per map
var minrooms: int = 20
## The max amount of rooms per map
var maxrooms: int = 30


var started: bool = false
var placed_special: bool = false
var map: Array[Array] = []
var area_map: Array[Array] = []
var area_count: int = 3
var map_count: int = 0
var room_queue: Array = []
var endrooms: Array = []
var boss_room: Vector2i = Vector2i(-1,-1)
var entrance_pos: Vector2i = Vector2i.ZERO
var areas_center: Array[Vector2] = []

func _ready():
	generate_map()
	show_map(map)
	init_map(area_map)
	var path: Array = find_path(entrance_pos)
	var length_area: int = len(path) / area_count
	place_shortest_path_to_boss(path, length_area)
	find_center_area(path)
	complete_area_map()

	for i in range(grid_width):
		for j in range(grid_height):
			if map[i][j] != 0:
				var scene = preload("res://Assets/Rooms/TestTemple/SimpleRoom/SimpleRoom.tscn").instantiate()
				scene.position = Vector3(i * ROOM_SIZE, (area_map[i][j] - 1) * 32, j * ROOM_SIZE)
				get_tree().root.add_child.call_deferred(scene)
	GAME.spawning_position = Vector3(entrance_pos.y * ROOM_SIZE, 0, entrance_pos.x * ROOM_SIZE)
	$Timer.start()


## Generate the map
func generate_map() -> void:
	started = true
	placed_special = false
	init_map(map)
	map_count = 0
	room_queue.clear()
	endrooms.clear()
	entrance_pos = try_placing_room(grid_width / 2, grid_height / 2)
	while room_queue.size() > 0:
		var pos = room_queue.pop_front()
		var x: int = pos.x
		var y: int = pos.y
		var created = false
		if x > 0:
			created = try_placing_room(x - 1, y) != Vector2i(-1,-1) or created
		if x < grid_width - 1:
			created = try_placing_room(x + 1, y) != Vector2i(-1,-1) or created
		if y > 0:
			created = try_placing_room(x, y - 1) != Vector2i(-1,-1) or created
		if y < grid_height - 1:
			created = try_placing_room(x, y + 1) != Vector2i(-1,-1) or created
		if not created:
			endrooms.append(Vector2i(x, y))
	
	if not placed_special:
		if map_count < minrooms:
			generate_map()
			return

		placed_special = true
		var furthest_rooms: Array = find_furthest_positions(endrooms)
		endrooms.erase(furthest_rooms[0])
		endrooms.erase(furthest_rooms[1])
		
		var entrance_room = furthest_rooms[0]
		entrance_pos = Vector2(furthest_rooms[0].y,furthest_rooms[0].x)
		map[entrance_room.x][entrance_room.y] = STARTING_ROOM
		
		
		
		boss_room = furthest_rooms[1]
		map[boss_room.x][boss_room.y] = BOSS_ROOM

		var treasure_room = pop_random_endroom()
		map[treasure_room.x][treasure_room.y] = TREASURE_ROOM

		var coin_room = pop_random_endroom()
		map[coin_room.x][coin_room.y] = COIN_ROOM

		if not treasure_room or not coin_room:
			generate_map()

## Pops a random room from the endrooms list. Returns (-1,-1) if endrooms list is empty
func pop_random_endroom() -> Vector2i:
	if endrooms.size() > 0:
		var index = randi() % endrooms.size()
		var pos = endrooms[index]
		endrooms.remove_at(index)
		return pos
	return Vector2i(-1,-1)

## Try placing a room at the given location and adds it to the map. Returns if it was successfull
func try_placing_room(x, y, room_type: int = NORMAL_ROOM) -> Vector2i:
	if map[x][y] != EMPTY:
		return Vector2i(-1,-1)

	if amount_adjacent_rooms(x, y) > 1:
		return Vector2i(-1,-1)

	if map_count >= maxrooms:
		return Vector2i(-1,-1)

	if randi() % 2 == 0 and (x != grid_width / 2 or y != grid_height / 2):
		return Vector2i(-1,-1)

	room_queue.append(Vector2i(x, y))
	map[x][y] = room_type
	map_count += 1

	return Vector2i(x,y)

## Counts the number of adjacent rooms
func amount_adjacent_rooms(x, y):
	var count = 0
	if x > 0 and map[x - 1][y] != EMPTY:
		count += 1
	if y > 0 and map[x][y - 1] != EMPTY:
		count += 1
	if y < grid_height - 1 and map[x][y + 1] != EMPTY:
		count += 1
	if x < grid_width - 1 and map[x + 1][y] != EMPTY:
		count += 1
	return count

## Initialize the map with empty values
func init_map(selected_map: Array[Array]) -> void:
	selected_map.resize(grid_width)
	for i in range(grid_width):
		selected_map[i] = []
		selected_map[i].resize(grid_height)
		selected_map[i].fill(EMPTY)

## Print the map
func show_map(selected_map: Array[Array]) -> void:
	var spacing: String = "--"
	for i in range(grid_width):
		spacing += "-"
	print(spacing)
	for i in range(grid_height):
		var text: String = "|"
		for j in range(grid_width):
			if selected_map[i][j] != 0:
				text += str(selected_map[i][j])
			else:
				text += " "
		print(text + "|")
	print(spacing)

## Function to find the shortest path between the entrance and the boss room
func find_path(pos: Vector2, acc: Array = []) -> Array:
	if pos in acc or map[pos.y][pos.x] in [EMPTY, COIN_ROOM, TREASURE_ROOM]:
		return []
	
	if map[pos.y][pos.x] == BOSS_ROOM:
		return acc + [pos]

	acc.append(pos)

	var directions = [
		Vector2(1, 0),
		Vector2(-1, 0),
		Vector2(0, 1),
		Vector2(0, -1)
	]

	for dir in directions:
		var new_pos = pos + dir

		if new_pos.x >= 0 and new_pos.x < grid_width and new_pos.y >= 0 and new_pos.y < grid_height:

			var path = find_path(new_pos, acc.duplicate())

			if path.size() > 0:
				return path

	return []

## Place the shortest path to the boss and divide it into areas
func place_shortest_path_to_boss(path: Array, length_area: int) -> void:
	var n: int = 0
	for i in range(len(path)):
		area_map[path[i].y][path[i].x] = n
		if i > n * length_area:
			n += 1

## Define the center of each area
func find_center_area(path: Array) -> void:
	var area_pos_list: Array[Array] = []
	for i in range(area_count):
		area_pos_list.append([])
	for pos in path:
		if area_map[pos.y][pos.x] == 0:
			path.erase(pos)
		elif area_map[pos.y][pos.x] - 1 < len(area_pos_list):
			area_pos_list[area_map[pos.y][pos.x] - 1].append(pos)
	for list in area_pos_list:
		var x_coord: float = 0.
		var y_coord: float = 0.
		for pos in list:
			x_coord += pos.x
			y_coord += pos.y
		areas_center.append(Vector2(x_coord/len(list),y_coord/len(list)))

## Fill the regions based on the nearest area center
func complete_area_map() -> void:
	for i in range(grid_height):
		for j in range(grid_width):
			if map[i][j] != 0 and area_map[i][j] == 0:
				var minimal_distance: float = 99999
				for center in areas_center:
					var distance: float = Vector2(i,j).distance_squared_to(Vector2(center.y,center.x))
					if minimal_distance > distance:
						minimal_distance = distance
						area_map[i][j] = areas_center.find(center) + 1

## Find the furthest positions in the list of positions given
func find_furthest_positions(positions: Array) -> Array:
	var max_distance = 0.0
	var furthest_pair = []
	for i in range(len(positions)):
		for j in range(i + 1, positions.size()):
			var distance = positions[i].distance_to(positions[j])
			if distance > max_distance:
				max_distance = distance
				furthest_pair = [positions[i], positions[j]]
	return furthest_pair


func _on_timer_timeout():
	EVENTS.emit_signal("map_generated")
