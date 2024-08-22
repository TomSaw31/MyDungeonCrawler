extends Node3D
class_name Item
## Items can be used and trigger a specific behavior

## The data of the iteem
@export var item_data: ItemData = null : set = set_item_data

func _ready() -> void:
	var model: Node = item_data.model.instantiate()
	model.position = position
	add_child(model)

## Set the data of the item
func set_item_data(value: ItemData) -> void:
	item_data = value

func interaction() -> void:
	EVENTS.emit_signal("item_collected",item_data)
	call_deferred("queue_free")
