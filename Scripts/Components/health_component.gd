extends Node3D
class_name HealthComponent
## Component that contains a basic Health System



## Health value
@export var health: float = 100

## Max Health value
@export var max_health: float = 100

###  Functions

## Update the health contained in the component according to the cost
func update_health(cost: float = 0) -> void:
	health = clamp(health - cost, 0, max_health)
	if health < 0.5:
		health = 0
	if owner is Player:
		owner.hud.bars.update_health(owner.health_component.health, owner.health_component.max_health)

