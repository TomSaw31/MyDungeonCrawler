extends SwordItem
## TEST

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func use_item():
	if has_enough_mana() and is_cooldown_finished():
		animation_player.play("swing")
		start_cooldown()


func _on_animation_player_animation_finished(_anim_name):
	rotation = Vector3(0,0,0)
