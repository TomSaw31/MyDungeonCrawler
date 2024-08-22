extends PlayerState
## The default state of the player

## The walking speed
const WALKING_SPEED: float = 5.0
## The sprinting speed
const SPRINTING_SPEED: float = 10.0
## Time during the jump buffering is allowed (pressing the jump button too early)
const JUMP_BUFFER_TIME: float = 0.2
## Time during the coyote jump is possible (pressing the jmup button in air)
const JUMP_COYOTE_TIME: float = 0.2

## Timer used for the jump buffer
@onready var jump_buffer_timer: Timer = $"../../Timers/JumpBuffer"
## Timer used for the coyote jump
@onready var coyote_timer: Timer = $"../../Timers/CoyoteTimer"

## Check interaction,handle jump, update the movement
func physics_update(delta: float) -> void:
	player.check_interaction()
	
	player.head.position.y = lerp(player.head.position.y, 0.75, delta * player.lerp_speed)
	if player.is_on_floor():
		coyote_timer.start(JUMP_COYOTE_TIME)
		if Input.is_action_pressed("sprint"):
			player.current_speed = SPRINTING_SPEED
		else:
			player.current_speed = WALKING_SPEED
	else:
		player.velocity.y = player.velocity.y - player.get_gravity_player() * delta


	if (Input.is_action_just_pressed("jump") and not coyote_timer.is_stopped()) or (not jump_buffer_timer.is_stopped() and player.is_on_floor()):
		player.velocity.y = -player.jump_velocity
		jump_buffer_timer.stop()
		coyote_timer.stop()
		
	var input_dir: Vector2 = Input.get_vector("left", "right", "forward", "backward")
	player.direction = lerp(player.direction,(player.head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * player.lerp_speed)
	if player.direction:
		player.velocity.x = player.direction.x * player.current_speed * player.skill_speed
		player.velocity.z = player.direction.z * player.current_speed * player.skill_speed
	else:
		player.velocity.x = 0.0
		player.velocity.z = 0.0
	player.headbob(delta, input_dir)

## Handle multiple different inputs (jump, crouch, weapons, ..)
func input_state(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		player.head.rotate_y(-event.relative.x * player.SENSITIVITY)
		player.camera.rotate_x(-event.relative.y * player.SENSITIVITY)
		player.camera.rotation.x = clamp(player.camera.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	if event.is_action_pressed("jump"):
		jump_buffer_timer.start(JUMP_BUFFER_TIME)
			
	if event.is_action_pressed("crouch"):
		if player.is_on_floor():
			player.state_machine.set_state("CrouchState")
		
	if event.is_action_pressed("item1"):
		owner.switch_item(0)
	elif event.is_action_pressed("item2"):
		owner.switch_item(1)
	elif event.is_action_pressed("item3"):
		owner.switch_item(2)
	elif event.is_action_pressed("item4"):
		owner.switch_item(3)
	elif event.is_action_pressed("item5"):
		owner.switch_item(4)
	if event.is_action_pressed("inventory"):
		owner.state_machine.set_state("InventoryState")
