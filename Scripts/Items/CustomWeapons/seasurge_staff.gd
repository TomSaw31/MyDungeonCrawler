extends CustomItem
class_name SeasurgeStaff
## Primary action : Shoot water projectiles
## Secondary action : Create a buble when directed to water


## Max range of the bubble
const MAX_RANGE: float = 15.

##Max size of the bubble
const MAX_SIZE: float = 2.5

## Speed of the growth of the bubble
const GROWING_SPEED: int = 25

## Speed of the bubble to move
const DISTANCE_SPEED: float = 0.5

## Item that creates buble on water when used on water and shoots water projectiles
@onready var bubble_scene: PackedScene = preload("res://Scenes/Projectiles/Items/WaterBubbleProjectile.tscn")

## Range used for the bubble
var v_range: float = MAX_RANGE

## Used to store the bubble
var projectile: Node = null

## The size of the bubble
var size: float = 0

var mana_cost_counter: float = 0

func _ready() -> void:
	set_process(false)

## Create the projectiles
func use_item_pressed() -> void:
	if has_enough_mana(1) and projectile == null:
		var target: Node3D = GAME.player.use_item_raycast(MAX_RANGE).get_collider()
		if target != null and target.has_node("WaterComponent"):
			projectile = bubble_scene.instantiate()
			projectile.position = target.position
			v_range = 1.25 * projectile.position.distance_to(GAME.player.position)
			get_tree().root.add_child.call_deferred(projectile)
			set_process(true)

## Release the water bubble if created
func use_item_released() -> void:
	if projectile != null:
		set_process(false)
		projectile.explode()
		size = 0.001
		mana_cost_counter = 0
		projectile = null

func _process(delta: float) -> void:
	var raycast = GAME.player.use_item_raycast(v_range)
	if raycast.get_collider() == null:
		projectile.position = lerp(projectile.position,raycast.global_transform.origin - raycast.global_transform.basis.z * v_range,delta * (MAX_SIZE + 2 - size))
	elif has_enough_mana(1):
		projectile.position = lerp(projectile.position,raycast.get_collision_point(), delta * (MAX_SIZE + 2 - size))
		if raycast.get_collider().has_node("WaterComponent"):
			if mana_cost_counter < item_data.mana_cost:
				size += delta
				mana_cost_counter += delta * GROWING_SPEED
				decrease_mana(delta * GROWING_SPEED)
	projectile.scale = Vector3(size,size,size)
	

func _input(event) -> void:
	if event.is_action_pressed("scroll_down"):
		v_range = clampf(v_range - DISTANCE_SPEED, 0., MAX_RANGE)
	if event.is_action_pressed("scroll_up"):
		v_range = clampf(v_range + DISTANCE_SPEED, 0., MAX_RANGE)
	
