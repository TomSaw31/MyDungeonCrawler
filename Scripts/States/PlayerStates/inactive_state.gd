extends PlayerState
## State theat stops the player and give it back its velocity when exiting

## Used to save the velocity of the player
var velocity_save: Vector3 = Vector3.ZERO

## Save and reset velocity
func enter_state() -> void:
	velocity_save = player.velocity
	player.velocity = Vector3.ZERO
	
### Give back the velocity to the player
func exit_state() -> void:
	player.velocity = velocity_save
