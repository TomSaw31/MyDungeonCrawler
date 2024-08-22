extends Node3D
class_name FloatingComponent
## Component that allows to change the y axis position based on the water level

## Used to know the initial water level
var base_level: float = 0
## Used to know the current level when increasing/ decreasing
var current_level: float = 0
## Define the water level of the actor
var water_level: float = 0

func _ready() -> void:
	EVENTS.connect("water_level_changed", update_water_level)
	set_physics_process(false)
	base_level = get_parent().position.y
	water_level = base_level
	

## Update the water level. If the water level is lower than the initial level, the owner of thhe component is set at the initial level
func update_water_level(new_level: float) -> void:
	if base_level <= new_level:
		water_level = new_level
		set_physics_process(true)
	else:
		print("below base level")

func _physics_process(delta: float) -> void:
	current_level = lerp(current_level, water_level, delta)
	get_parent().position.y  = current_level
	if abs(current_level - water_level) < 0.05:
		set_physics_process(false)
		current_level = water_level
		get_parent().position.y  = water_level
