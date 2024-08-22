extends Node
class_name InventoryDataManager
## Register all information of the player (items, skills,...)

const SKILL_MANA_MODIFIER_NAME = "skill_mana_modifier"
## The different item types
enum ITEM_TYPE {ITEM, SWORD, BOW, SHIELD, CONSUMMABLE}
## The different element types. Used to create interactions between elements.
enum ELEMENT_TYPES {NORMAL, FIRE, WATER, PLANT, ROCK, ICE, LIGHT, SHADOW}

## Contains the player itemstacks
var item_stack_list: Array[ItemStack] = []
## Indicates the levels of the unlocked skills (0 is for locked skills)
var skills: Dictionary = {"damage": 0, "mana": 0, "health": 0, "resistance": 0, "speed": 0, "critical_hit": 0 }
## The number of skill points
var skill_points: int = 36
## The different keys found in the levels
var keys: Array = []
## The 5 equipped items
var equipped_items: Array[ItemData] = [null,null,null,null,null]

# MANA
## Mana max add modifiers
var max_mana_add: Dictionary = {}
## Mana max mult modifiers
var max_mana_mult: Dictionary = {}

class ItemStack:
	## An item stack conatins an item and its corresponding amount
	
	## Amount of the  same items
	var stack: int = 0
	## The item data
	var item: ItemData = null
	
	func _init(_stack: int, _item: ItemData) -> void:
		stack = _stack
		item = _item

func _ready() -> void:
	EVENTS.connect("item_collected", _on_EVENTS_item_collected)
	max_mana_mult[SKILL_MANA_MODIFIER_NAME] = 1.

## Add an item to the inventory
func _append_item(item: ItemData, stack: int = 1) -> void:
	var item_stack_id: int = _find_item_id(item)
	var item_stack: ItemStack = null
	
	if item_stack_id == -1:
		item_stack = ItemStack.new(stack, item)
		item_stack_list.append(item_stack)
	else:
		item_stack = item_stack_list[item_stack_id]
		item_stack.stack += stack
	EVENTS.emit_signal("item_added_to_inventory", item_stack)
		
## Remove an item from the inventory
func _remove_item(item: ItemData, stack: int = 1) -> void:
	var item_stack_id = _find_item_id(item)
	if item_stack_id == -1:
		push_error("%s could not be removed from the list. No ItemStack corresponding was found" %item.item_name)
	else:
		var item_stack: ItemStack = item_stack_list[item_stack_id]
		item_stack.stack -= stack
		EVENTS.emit_signal("item_removed_from_inventory", item_stack)
		if item_stack_list[item_stack_id].stack <= 0:
			item_stack_list.remove_at(item_stack_id)

## Find the id of a certain item in the inventory
func _find_item_id(item: ItemData) -> int:
	for i in range(len(item_stack_list)):
		if item_stack_list[i].item == item:
			return i
	return -1

## TEST shows the inventory in the terminal
func _print_inventory() -> void:
	print("INVENTORY")
	for item_stack in item_stack_list:
		print(item_stack.item.item_name + " : " + str(item_stack.stack))
	print("-----")
	
func _on_EVENTS_item_collected(item: ItemData) -> void:
	_append_item(item)

## Returns all the items of the specified type found in the player's inventory
func get_items_of_type(item_type: ITEM_TYPE):
	'''Get all items of a certain type'''
	var list: Array[Item] = []
	for item_stack in item_stack_list:
		if item_stack.item.item_type == item_type:
			list.append(item_stack.item)
	return list

## Return if the item (and its amound) is found in the inventory
func has_item(item_data: ItemData, amount: int = 1) -> bool:
	'''Check if a certain amount of an item is present in the inventory'''
	var id: int = _find_item_id(item_data)
	if id == -1:
		return false
	else:
		return item_stack_list[id].stack >= amount

## Updates the unlocked skills
func update_skills(type: String, level: int, skill_type: String) -> void:
	var skill_percents: Vector4 = Vector4(1.0, 1.25, 1.5, 2.0)
	skills[type] = level
	match skill_type:
		"speed": 
			GAME.player.skill_speed = skill_percents[skills["speed"]]
		"mana":
			GAME.player.mana_component.update_mana()
			max_mana_mult[SKILL_MANA_MODIFIER_NAME] = skill_percents[skills["mana"]]
			update_mana_max_player()
		"health":
			GAME.player.skill_health = skill_percents[skills["health"]]
		"damage":
			GAME.player.skill_damage = skills["damage"] * 10
		"critical_hit":
			GAME.player.skill_critical_hit = skills["critical_hit"] * 5
		"resistance":
			GAME.player.skill_resistance = skills["resistance"] * 10
			
## Update the skill points
func update_skill_points(n: int) -> void:
	skill_points = n
	EVENTS.emit_signal("skill_point_modified")

## Update the equipped items in the inventory
func update_equipped_items(item_data_list: Array[ItemData]) -> void:
	equipped_items = item_data_list
	EVENTS.equipped_items_switched.emit(equipped_items)

## Update the mana max in the player mana component
func update_mana_max_player() -> void:
	var add_modif: Array[float] = []
	for key in max_mana_add.keys():
		add_modif.append(max_mana_add[key])
	var mult_modif: Array[float] = []
	for key in max_mana_mult.keys():
		mult_modif.append(max_mana_mult[key])
	GAME.player.mana_component.update_mana_max(add_modif,mult_modif)
	GAME.player.mana_component.update_mana()
