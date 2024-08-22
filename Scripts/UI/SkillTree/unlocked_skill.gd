extends TextureButton
## Used to display which skills are already unlocked

## The skill's name
@export var s_name: String = ""
## The skill's description
@export var s_description: String = ""
## The skill level
@export var s_level: int = 0
## Background indicating the level of the skill
@onready var background: TextureRect = $Background
## Background use in the unlocking animation to be in front of the new one
@onready var background_fading: TextureRect = $BackgroundFading
## Animation player used when unlocking a new skill level
@onready var animation_player: AnimationPlayer = $AnimationPlayer
## Used to know when the unlocking animation is finished
var is_unlocking: bool = false
## Used to know when it is selected or hovered
var in_focus: bool = false


## Update the indication of which skills are unlocked based on the type of skill
func update_unlocked_skill(skill_name: String, skill_description: String, skill_level: int, skill_texture: Texture2D) -> void:
		texture_normal = skill_texture
		s_name = skill_name
		s_description = skill_description
		s_level = skill_level
		is_unlocking = true
		animation_player.play("unlocking")
		match s_level:
			1: background.texture = preload("res://Assets/Textures/UI/HUD/Skills/unlocked_1.png")
			2: background.texture = preload("res://Assets/Textures/UI/HUD/Skills/unlocked_2.png")
			3: background.texture = preload("res://Assets/Textures/UI/HUD/Skills/unlocked_3.png")
			
func _on_focus_entered() -> void:
	if not in_focus:
		in_focus = true
		if texture_normal == null:
			GAME.player.hud.skill_tree.update_infos_unlocked(s_name,s_description, background.texture)
		else:
			GAME.player.hud.skill_tree.update_infos_unlocked(s_name,s_description, texture_normal)
		animation_player.play("hovering")


func _on_mouse_entered() -> void:
	if not in_focus:
		in_focus = true
		if texture_normal == null:
			GAME.player.hud.skill_tree.update_infos_unlocked(s_name,s_description, background.texture)
		else:
			GAME.player.hud.skill_tree.update_infos_unlocked(s_name,s_description, texture_normal)
		animation_player.play("hovering")

func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "unlocking":
		background_fading.texture = background.texture
		is_unlocking = false


func _on_focus_exited():
	if in_focus:
		in_focus = false
		animation_player.play_backwards("hovering")

func _on_mouse_exited():
	if in_focus:
		in_focus = false
		animation_player.play_backwards("hovering")
