extends Node
## Used to load files and use loot tables in the game

## Contains all items
var item_resource_list: Array[ItemData] = []
## Contains every item in the game
var all_item_resource_list: Array[ItemData] = []
## Debug item given if no other items are remaining
var debug_item: Resource = preload("res://Assets/Resources/Items/Debug/debug_item.tres")

func _ready() -> void:
	item_resource_list = get_items_resources()
	all_item_resource_list = get_items_resources()
	
## Returns all files names found in the specified folder path
func get_all_files_from_path(path: String) -> Array[String]:
	'''Get all files names from the specified path (and not the sub directories)'''
	var file_paths: Array[String] = []
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		var file_path: String = path + "/" + file_name
		if not dir.current_is_dir():
			file_paths.append(file_path)
		file_name = dir.get_next()
	return file_paths

## Returns all items resources found in res://Assets/Resources/Items/
func get_items_resources() -> Array[ItemData]:
	var item_list: Array[ItemData] = []
	for file_name in get_all_files_from_path("res://Assets/Resources/Items/"):
		var res: Resource = load(file_name)
		if res is ItemData:
			item_list.append(res)
		else:
			print("debug : Item Resource in Items folder not of ItemData type")
	return item_list

## Returns a random item and delete it from the item list
func get_random_item() -> Resource:
	if len(item_resource_list) > 0:
		var item_index: int = randi_range(0, len(item_resource_list)-1)
		var item_res: Resource = item_resource_list[item_index]
		item_resource_list.remove_at(item_index)
		return item_res
	else:
		print("debug : no random item left")
		return debug_item
