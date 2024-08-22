extends PlayerState
## TEST : Allow to fly

func physics_update(delta: float) -> void:
	player.check_interaction()
	
	player.head.position.y = lerp(player.head.position.y, 0.75, delta * player.lerp_speed)
	if Input.is_action_pressed("jump"):
		player.position.y += 15 * delta
	player.velocity.y = 0
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	player.direction = lerp(player.direction,(player.head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * player.lerp_speed)
	if player.direction:
		player.velocity.x = player.direction.x * player.current_speed * 3
		player.velocity.z = player.direction.z * player.current_speed * 3
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
	player.headbob(delta, input_dir)

func input_state(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.head.rotate_y(-event.relative.x * player.SENSITIVITY)
		player.camera.rotate_x(-event.relative.y * player.SENSITIVITY)
		player.camera.rotation.x = clamp(player.camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
