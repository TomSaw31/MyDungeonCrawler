extends Button
class_name ItemSlot
## A slot of the inventory containing an item data

## The default icon path when the slot is empty
const DEFAULT_EMPTY_SLOT_TEXTURE_PATH: String = "res://icon.svg"

## Define is the slot is selected
@export var is_selected: bool = false
## The item data of the slot
@export var item_data: ItemData = null
## Define if the item slot is empty
@export var is_equipped: bool = false
## Index if equipment slot
@export var equipment_index: int = 0

## Triggered  when an item is selected
signal item_selected(item_data: ItemData)
## Triggered when the selected equipment slot item is changed
signal item_equipment_selected_changed(index: int)

func _ready() -> void:
	refresh()

func refresh() -> void:
	if item_data == null and is_equipped:
		icon = preload(DEFAULT_EMPTY_SLOT_TEXTURE_PATH)
	else:
		icon = item_data.texture

func _on_pressed() -> void:
	if is_equipped:
		item_equipment_selected_changed.emit(equipment_index)
	else:
		item_selected.emit(item_data)
	
