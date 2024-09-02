extends Node3D

const EMPTY = 0
const NORMAL_ROOM = 1
const BOSS_ROOM = 2
const TREASURE_ROOM = 3
const COIN_ROOM = 4
const STARTING_ROOM = 5

## The width of the map
var grid_width: int = 25
## The height of the map
var grid_height: int = 25
## The min amount of rooms per map
var minrooms: int = 30
## The max amount of rooms per map
var maxrooms: int = 40


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

func _ready():
	generate_map()
	show_map(map)
	init_map(area_map)
	var path: Array = find_path(entrance_pos)
	var length_path: int = len(path) / area_count
	var n: int = 0
	for i in range(len(path)):
		area_map[path[i].y][path[i].x] = n
		if i > n * length_path:
			n += 1

	show_map(area_map)
	
## Generate the map
func generate_map() -> void:
	started = true
	placed_special = false
	init_map(map)
	map_count = 0
	room_queue.clear()
	endrooms.clear()
	entrance_pos = try_placing_room(grid_width / 2, grid_height / 2, STARTING_ROOM)
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

		boss_room = endrooms.pop_back()
		
		if boss_room != Vector2i(-1,-1):
			map[boss_room.x][boss_room.y] = BOSS_ROOM

		var treasure_room = pop_random_endroom()
		if treasure_room != Vector2i(-1,-1):
			map[treasure_room.x][treasure_room.y] = TREASURE_ROOM

		var coin_room = pop_random_endroom()
		if coin_room != Vector2i(-1,-1):
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

	# If there is already enough neighbours
	if amount_adjacent_rooms(x, y) > 1:
		return Vector2i(-1,-1)

	# If the max amount of rooms is reached
	if map_count >= maxrooms:
		return Vector2i(-1,-1)

	# Random chance of giving up
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
	var spacing: String = "-"
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

# Function to find a path recursively in GDScript
func find_path(pos: Vector2, acc: Array = []) -> Array:
	# Check if the current position is out of bounds or already visited
	if pos in acc or map[pos.y][pos.x] in [EMPTY, COIN_ROOM, TREASURE_ROOM]:
		return []
	
	# If the destination is reached, return the accumulated path
	if map[pos.y][pos.x] == BOSS_ROOM:
		return acc + [pos]

	# Add the current position to the path
	acc.append(pos)

	# Define the possible directions to move: Right, Left, Down, Up
	var directions = [
		Vector2(1, 0),  # Right
		Vector2(-1, 0), # Left
		Vector2(0, 1),  # Down
		Vector2(0, -1)  # Up
	]

	# Try each direction
	for dir in directions:
		var new_pos = pos + dir

		# Ensure new position is within bounds
		if new_pos.x >= 0 and new_pos.x < grid_width and new_pos.y >= 0 and new_pos.y < grid_height:
			# Recursively search from the new position
			var path = find_path(new_pos, acc.duplicate())  # Use .duplicate() to pass a copy of acc

			# If a valid path is found, return it
			if path.size() > 0:
				return path

	# No valid path found, backtrack
	return []
