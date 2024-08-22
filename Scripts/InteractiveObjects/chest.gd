extends StaticBody3D
## Chests contain items for the player

## Item contained in the chest
@export var item_data: ItemData = null

## Define if the chest is already opened
var opened: bool = false

func _ready() -> void:
	if item_data == null:
		item_data = LOOT_TABLES.get_random_item()

## Open the chest if not already done
func interaction() -> void:
	if not opened:
		$AnimationPlayer.play("ArmatureAction_002")
		opened = true
		$Timer.start(1)

func _on_timer_timeout() -> void:
	EVENTS.emit_signal("item_collected", item_data)
