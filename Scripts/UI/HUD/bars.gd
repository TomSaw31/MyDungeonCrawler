extends VBoxContainer
class_name Bars
## Contains all HUD stats bars

const LOW_HEALTH_PERCENT_THRESHOLD: float = 0.15
## The circular mana bar
@onready var mana_bar: TextureProgressBar = $ManaBar
## The mana level
@onready var mana_level: Label = $ManaBar/Control/ManaLevel
## The circular health bar
@onready var health_bar: TextureProgressBar = $HealthBar
## The health level
@onready var health_level: Label = $HealthBar/Control/HealthLevel
## Animation player used to play animation on the health bar
@onready var health_anim_player: AnimationPlayer = $HealthBar/HealthAnimPlayer
## Animation player used to play animation on the mana bar
@onready var mana_anim_player: AnimationPlayer = $ManaBar/ManaAnimPlayer

## Used to save the value of the health for the animation
var health: float = 0
## Used to save the value of the max health for the animation
var health_max: float = 0

## Update the mana bar
func update_mana(level: float, max_level: float) -> void:
	mana_bar.max_value = max_level
	mana_bar.value = level
	mana_level.text = str(int(level))
	if level == max_level:
		mana_anim_player.play("full_mana")
	
## Update the health bar
func update_health(level: float, max_level: float) -> void:
	health_bar.max_value = max_level
	health_bar.value = level
	health_level.text = str(int(level))
	health = level
	health_max = max_level
	if level == max_level:
		health_anim_player.speed_scale = 1
		health_anim_player.play("full_health")
	elif level / max_level < LOW_HEALTH_PERCENT_THRESHOLD:
		health_anim_player.speed_scale = clamp(1/(level/max_level),1,5)
		health_anim_player.play("low_health")


func _on_health_anim_player_animation_finished(anim_name: String) -> void:
	if anim_name == "low_health" and health / health_max < LOW_HEALTH_PERCENT_THRESHOLD:
		health_anim_player.play("low_health")
		health_anim_player.speed_scale = clamp(1/(health/(health_max * LOW_HEALTH_PERCENT_THRESHOLD)),1,5)
