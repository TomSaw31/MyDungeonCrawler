extends Projectile
## Giant water bubble used as a projectile

@onready var water_detection: Area3D = $WaterDetection

func explode() -> void:
	for body in water_detection.get_overlapping_bodies():
		if body.has_node("WaterInteractionComponent"):
			body.water_interaction()
	queue_free()


func _on_inner_detection_area_entered(area: Area3D) -> void:
	if area == GAME.player.head_hitbox:
		GAME.player.hud.head_underwater(true)

func _on_inner_detection_area_exited(area: Area3D) -> void:
	if area == GAME.player.head_hitbox:
		GAME.player.hud.head_underwater(false)
