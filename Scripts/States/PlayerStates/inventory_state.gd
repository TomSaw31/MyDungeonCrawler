extends PlayerState
## State used when the player is inside the inventory and give it back its velocity when exiting

## Used to save the velocity of the player
var velocity_save: Vector3 = Vector3.ZERO

## Show the inventory
func enter_state() -> void:
	player.hud.show_inventory()
	EVENTS.emit_signal("inventory_opened", true)
	velocity_save = player.velocity
	player.velocity = Vector3.ZERO

## Switch back to the previous state
func input_state(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		player.state_machine.set_state(player.state_machine.previous_state)

## Hide the inventory
func exit_state() -> void:
	player.hud.hide_inventory()
	EVENTS.emit_signal("inventory_opened", false)
	player.velocity = velocity_save
