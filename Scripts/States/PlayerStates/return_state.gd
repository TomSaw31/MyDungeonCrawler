extends PlayerState
## TEST
const RETURN_SPEED: int = 50
var velocity_saved: Vector3



func enter_state() -> void:
	velocity_saved = player.velocity
	player.standing_collision_shape.disabled = true

	
func physics_update(delta: float) -> void:
	player.velocity = Vector3.ZERO
	var direction: Vector3 = (player.projection.position - player.position).normalized()
	var movement: Vector3 = direction * RETURN_SPEED * delta
	player.position += movement
	if player.position.distance_to(player.projection.position) < 0.5:
		player.state_machine.set_state(player.state_machine.previous_state)


func exit_state() -> void:
	'''Reset the Neon Projection'''
	player.standing_collision_shape.disabled = false
	player.rotation = player.neon_projection_rotation
	player.global_position = player.neon_projection_position
	player.projection.queue_free()
	player.projection = null
	player.velocity = velocity_saved
	GAME.time_scale = 1
