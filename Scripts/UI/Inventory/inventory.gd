extends Control

## The item slot scene
const ITEM_SLOT: PackedScene = preload("res://Scenes/UI/ItemSlot.tscn")
## The argb color when a slot cannot be selectionned
const UNSELECTED_COLOR: Color = Color(0.5, 0.5, 0.5, 0.5)

## Contains the item slots
@onready var item_slots: Array[ItemSlot] = [$VBoxContainer/ItemSlotList/ItemSlot0,$VBoxContainer/ItemSlotList/ItemSlot1,$VBoxContainer/ItemSlotList/ItemSlot2,$VBoxContainer/ItemSlotList/ItemSlot3,$VBoxContainer/ItemSlotList/ItemSlot4]
## Contains all items
@onready var item_list: GridContainer = $VBoxContainer/HBoxContainer/ItemList

## Represent the current selected slot
var selected_slot: int = 0

## Refresh all items found in the inventory
func refresh() -> void:
	for item_slot in item_slots:
		item_slot.refresh()

## Refresh the item list
func refresh_item_list() -> void:
	for child in item_list.get_children():
		child.queue_free()
	for item_stack in INVENTORY.item_stack_list:
		var item_slot_scene = ITEM_SLOT.instantiate()
		item_slot_scene.item_data = item_stack.item
		item_slot_scene.refresh()
		item_slot_scene.connect("item_selected", select_item)
		item_list.add_child(item_slot_scene)

## Select an item to be the active item
func select_item(item_data: ItemData) -> void:
	for i in range(len(item_slots)):
		if i != selected_slot and item_data == item_slots[i].item_data:
			item_slots[i].item_data = item_slots[selected_slot].item_data
			item_slots[i].refresh()
			item_slots[selected_slot].item_data = item_data
			item_slots[selected_slot].refresh()
	item_slots[selected_slot].item_data = item_data
	item_slots[selected_slot].refresh()
	refresh_item_list()
	update_equipped_item_in_inventory()

## Switch selected item slot equipment
func switch_selected_item_equipment(index: int) -> void:
	selected_slot = index

## Update equipped items in the INVENTORY autoload
func update_equipped_item_in_inventory() -> void:
	var equipped_items: Array[ItemData] = []
	for i in range(len(item_slots)):
		equipped_items.append(item_slots[i].item_data)
	INVENTORY.update_equipped_items(equipped_items)
