extends CharacterBody3D
class_name Player
## The class used by the player to play the game

## Used as the position of the head
@onready var head: Node3D = $Head
## Used as the main fps camera
@onready var camera: Camera3D = $Head/Camera
## Collision shape used while crouching
@onready var crouching_collision_shape: CollisionShape3D = $CrouchingCollisionShape
## Collision shape used while standing
@onready var standing_collision_shape: CollisionShape3D = $StandingCollisionShape
## Raycast used to know if the player can un-crouch if there are no obstacles above
@onready var crouching_raycast: RayCast3D = $RayCasts/CrouchingRayCast
## Raycast used to know if the player is touching the ground
@onready var floor_raycast: RayCast3D = $RayCasts/FloorRayCast
## Raycast used generally by custom items
@onready var item_ray_cast: RayCast3D = $Head/Camera/ItemRayCast
## Statemachine used to switch between different states
@onready var state_machine: StateMachine = $StateMachine
## The different item sockets
@onready var item_sockets: Array[Node3D] = [$Head/Items/Item1,$Head/Items/Item2,$Head/Items/Item3,$Head/Items/Item4,$Head/Items/Item5]
## Raycast used for interaction
@onready var interaction_raycast: RayCast3D = $Head/Camera/InteractionRayCast
## HUD of the player
@onready var hud: HUD = $CanvasLayer/Hud
## Component used to handle the player's health system
@onready var health_component: HealthComponent = $Components/HealthComponent
## Component used to handle the player's mana system
@onready var mana_component: ManaComponent = $Components/ManaComponent
## Component used indicate the player's head's hitbox
@onready var head_hitbox: Area3D = $Head/HeadHitbox

# Settings
## The mouse head movement sensitivity
const SENSITIVITY: float = 0.0025

# Jump
## The height of a player jump
var jump_height: float = 7.5
## The time for the player to peak when jumping
var jump_time_to_peak: float = 0.5
## The time for the player to descent when jumping
var jump_time_to_descent: float = 0.5
## The jump velocity
@onready var jump_velocity: float = -jump_height / jump_time_to_descent
## The gravity used when jumping
@onready var jump_gravity: float = jump_height / (jump_time_to_peak ** 2)
## The gravity used during the fall phase of the jump
@onready var fall_gravity: float = jump_height / (jump_time_to_descent ** 2)

# Weapons
## The index representing which item is equiped
var item_index: int = 0
## Contains the equipped items
var equipped_items: Array[ItemData] = [null,null,null,null,null]


# Skills
## Bonus speed multiplier added with unlocked skills
var skill_speed: float = 1
## Bonus damage added with unlocked skills
var skill_damage: int = 0
## Bonus resistance added with unlocked skills
var skill_resistance: float = 0
## Bonus health multiplier added with unlocked skills
var skill_health: float = 1
## Bonus critical hit added with unlocked skills
var skill_critical_hit: float = 0

# Head bobbing
## The frequency of head bobbing
const BOB_FREQ: int = 2
## The amplitude of head bobbing
const BOB_AMP: float = 0.08
## Used to create head bobbing
var t_bob : float = 0.0

# Movement
## Duration of the movement slide effect
var slide_timer: float = 0.0
## Max duration of the movement slide effect
var slide_timer_max: float = 1.0
## Lerp speed of the movment
var lerp_speed: float = 10.0
## Direction of the movement
var direction: Vector3 = Vector3.ZERO
## Base gravity for the player
var gravity: float = -19.6
## Speed variable used for the player movement
var current_speed: float = 5.0

# Misc
## The current target of the interaction
var interaction_target: Node3D = null

func _ready() -> void:
	GAME.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	switch_item(0)
	EVENTS.equipped_items_switched.connect(update_equipped_items_in_hand)
	mana_component.update_mana()
	health_component.update_health()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_full_screen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if event.is_action_pressed("exit"):
		get_tree().quit()
	if event.is_action_pressed("mouse"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("primary_action") or event.is_action_released("primary_action"):
		var item: CustomItem = null
		if len(item_sockets[item_index].get_children()) > 0:
			item = item_sockets[item_index].get_children()[0]
			if event.is_action_pressed("primary_action"):
				item.use_item()
				item.use_item_pressed()
			if event.is_action_released("primary_action"):
				item.use_item_released()
	if interaction_target != null:
		if event.is_action_pressed("interaction"):
			hud.start_interaction()
		if event.is_action_released("interaction"):
			hud.reset_interaction()


func _physics_process(_delta: float) -> void:
	move_and_slide()

## Return the current gravity during jump (jump gravity if moving upward and fall gravity if moving downward)
func get_gravity_player() -> float:
	return jump_gravity if velocity.y < 0.0 else fall_gravity

## Create a head bobbing effect on the camera depending of the input direction and delta time
func headbob(delta: float, input_dir: Vector2) -> void:
	t_bob += delta * velocity.length() * float(is_on_floor())
	if input_dir.x > 0:
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(-current_speed * 0.5), delta)
	elif input_dir.x < 0: 
		head.rotation.z = lerp_angle(head.rotation.z, deg_to_rad(current_speed * 0.5), delta)
	else:
		head.rotation.z = lerp_angle(head.rotation.z, 0, delta)
	var pos = Vector3.ZERO
	pos.y = sin(t_bob * BOB_FREQ) * BOB_AMP * 1/sqrt(skill_speed)
	pos.x = cos(t_bob * BOB_FREQ / 2) * BOB_AMP * 1/sqrt(skill_speed)
	camera.transform.origin = pos

## Switch between the different items depending of the argument
func switch_item(index: int) -> void:
	item_index = index
	for i in range(len(item_sockets)):
		if i == item_index:
			item_sockets[item_index].visible = true
		else:
			item_sockets[i].visible = false
	hud.switch_item(index)
	
## Update the equipped items in hand
func update_equipped_items_in_hand(items: Array[ItemData]) -> void:
	for i in range(len(items)):
		if items[i] == null:
			for child in item_sockets[i].get_children():
				child.queue_free()
		else:
			if items[i].item_scene == null:
				print("debug : item scene empty")
				return
			var scene: Node = items[i].item_scene.instantiate()
			scene.item_data = items[i]
			scene.position = item_sockets[i].position
			item_sockets[i].add_child(scene)


## Check if there is a possible interaction between the player and an actor that has the InteractionComponent
func check_interaction() -> void:
	var collider = interaction_raycast.get_collider()
	if collider != interaction_target:
		hud.hide_interaction()
		interaction_target = null
	if collider != null and collider.has_node("InteractionComponent"):
		interaction_target = collider
		hud.show_interaction(interaction_target.get_node("InteractionComponent"))


## Create an interaction between the player and the interaction target
func interact() -> void:
	if interaction_target != null:
		if interaction_target.has_method("interaction"):
			interaction_target.interaction()
		else:
			print("debug : no interaction method")
			if interaction_target.owner.has_method("interaction"):
				interaction_target.owner.interaction()
			
## Use a raycast depending of the lenght input and return the modified raycast. Used for item interaction such as aiming
func use_item_raycast(length: float) -> RayCast3D:
	item_ray_cast.target_position.z = -length
	return item_ray_cast
