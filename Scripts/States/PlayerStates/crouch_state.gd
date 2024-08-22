extends PlayerState
## The crouch state of the player

## The crouching speed
const CROUCHING_SPEED: float = 3.0

## The crouching depth. Control of how much the player the player crouch
var crouching_depth: float = -0.5


	
## Change the hitbox and speed of the player
func enter_state() -> void:
	player.crouching_collision_shape.disabled = false
	player.standing_collision_shape.disabled = true
	player.current_speed = CROUCHING_SPEED
	
## Check interaction, switch to the default state if the player can, update the movement
func physics_update(delta: float) -> void:
	player.check_interaction()
	
	if not Input.is_action_pressed("crouch") and not player.crouching_raycast.is_colliding():
		player.state_machine.set_state("DefaultState")
	else:
		player.head.position.y = lerp(player.head.position.y, 0.75 + crouching_depth, delta * player.lerp_speed)
		var input_dir = Input.get_vector("left", "right", "forward", "backward")
		player.direction = lerp(player.direction,(player.head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * player.lerp_speed)
		if player.direction:
			player.velocity.x = player.direction.x * player.current_speed
			player.velocity.z = player.direction.z * player.current_speed
		else:
			player.velocity.x = 0.0
			player.velocity.z = 0.0
		player.headbob(delta, input_dir)

## Change back the hitbox and speed of the player
func exit_state() -> void:
	player.crouching_collision_shape.disabled = true
	player.standing_collision_shape.disabled = false
	player.current_speed = CROUCHING_SPEED

func input_state(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.head.rotate_y(-event.relative.x * player.SENSITIVITY)
		player.camera.rotate_x(-event.relative.y * player.SENSITIVITY)
		player.camera.rotation.x = clamp(player.camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	
