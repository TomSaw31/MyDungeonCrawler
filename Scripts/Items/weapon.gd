extends Item
class_name CustomItem
## Main class for weapon items

## Timer used as a cooldown
var timer: Timer = null


func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(cooldown_finished)
	add_child(timer)
	
## Return if the cooldown is finished
func is_cooldown_finished() -> bool:
	return timer.is_stopped()


## Method used for child class to use item
func use_item() -> void:
	pass
	
## Method triggered when the item use key is pressed
func use_item_pressed() -> void:
	pass

## Method triggered when the item use key is 
func use_item_released() -> void:
	pass
	
## Triggered when the cooldown is finished
func cooldown_finished() -> void:
	pass

## Return if the player has enough mana to use the item
func has_enough_mana(mana: float = 0) -> bool:
	if mana == 0:
		return GAME.player.mana_component.has_enough_mana(item_data.mana_cost)
	else:
		return GAME.player.mana_component.has_enough_mana(mana)

## Remove the mana used by the item. If mana = 0, the default cost is used
func decrease_mana(mana: float = 0) -> void:
	if mana == 0:
		GAME.player.mana_component.update_mana(item_data.mana_cost)
	else:
		GAME.player.mana_component.update_mana(mana)
	
## Start the cooldown
func start_cooldown():
	timer.start(item_data.cooldown)
