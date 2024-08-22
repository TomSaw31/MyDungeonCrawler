extends StaticBody3D
class_name Door
## Doors are used to limits different areas. They can be locked and unlocked with keys

@onready var interaction_component: InteractionComponent = $InteractionComponent

## The distance the doors must move
const OFFSET: Vector3 = Vector3(1,0,0)

## Used to know if the door is openend
var is_opened: bool = false

## Used to know if the door is currently switching states
var is_moving: bool = false

## Used to know where the door should when opening/closing
var target_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	set_process(false)

## Open the door when closed and close the door when opened
func interaction() -> void:
	if not is_moving:
		is_moving = true
		set_process(true)
		if is_opened:
			interaction_component.info = "Open"
			target_position = position + OFFSET
		else:
			interaction_component.info = "Close"
			target_position = position - OFFSET


func _process(delta: float) -> void:
	position = lerp(position, target_position, delta * 10)
	if position.distance_to(target_position) < 0.01:
		set_process(false)
		is_moving = false
		is_opened = false if is_opened else true
