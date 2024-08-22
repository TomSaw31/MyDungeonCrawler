extends Control
## The tree containing all skills and can be moved

## Counter to keep track of the amount of remaining skill points
@onready var skill_points_counter: Label = $HBoxContainer/ContainerInfos/InfoVBox/HBoxPoints/PanelContainer/SkillPointsCounter
## Text that displays the cost of the skill xhen unlocked
@onready var skill_points_animation: Label = $HBoxContainer/ContainerInfos/InfoVBox/HBoxPoints/PanelContainer/SkillPointsAnimation
## The skill's name
@onready var skill_name: Label = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/SkillName
## The skill's icon
@onready var skill_icon: TextureRect = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/PanelContainer/SkillIcon
## The skill's icon used as an animation
@onready var skill_icon_animation: TextureRect = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/PanelContainer/SkillIconAnimation
## The skill's description
@onready var skill_description: Label = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/SkillDescription
## The center of the tree
@onready var center: Control = $HBoxContainer/VBoxContainer/PanelContainer/Center
## The animation used to play the unlocking animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
## The animation player used to color skill points
@onready var skill_point_color_anim_player: AnimationPlayer = $SkillPointColor
## Contains the cost of the skill
@onready var cost_box: HBoxContainer = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/PanelContainer/CostBox
## Indicates the cost of the skill 
@onready var cost: Label = $HBoxContainer/ContainerInfos/InfoVBox/VBoxInfos/PanelContainer/CostBox/Cost
## Time used for the rainbow animation of the skill point texture
var time: float = 0
## Indicates if the player is moving the tree
var is_moving: bool = false
## Indicates if the player is currently unlocking a skill
var is_currently_unlocking_skill: bool = false

## Used to know if the player's mouse is inside the skill tree window
var inside_skill_tree: bool = false
## Used to know if the player can move the skill tree
var can_move_skill_tree: bool = false

func _ready() -> void:
	EVENTS.connect("skill_point_modified", update_skill_points)
	update_skill_points()
	skill_point_color_anim_player.play("rainbow")

## Modify the text indication of the remaining amount of skill points
func update_skill_points() -> void:
	skill_points_counter.text = " × " + str(INVENTORY.skill_points)

## Update the information found on the side depending of the selected skill
## If skill is null, it means that the info belong to a skill in the recap section on the left side of the skill tree
func update_infos(skill: SkillNode) -> void:
	skill_name.text = skill.skill_name
	skill_description.text = skill.skill_description
	if skill.unlocked:
		skill_icon.texture = skill.texture_normal
	else:
		skill_icon.texture = skill.lock.texture
		cost.text = "× " + str(skill.skill_level)
	cost_box.visible = not skill.unlocked
	
## Update the information found on the side depending of the unlocked skill in the left section of the menu containing the tree
func update_infos_unlocked(s_name: String = "", s_description: String = "", s_texture: Texture2D = null) -> void:
	skill_name.text = s_name
	skill_description.text = s_description
	skill_icon.texture = s_texture
	cost_box.visible = false
	
## Play the cost/unlocking animation
func play_cost_animation(skill: SkillNode) -> void:
	if INVENTORY.skill_points >= 10:
		skill_points_animation.text = "  "
	else:
		skill_points_animation.text = ""
	skill_points_animation.text += "   -" + str(skill.skill_level)
	skill_points_animation.global_position = skill_points_counter.global_position
	skill_icon_animation.modulate = Color(1,1,1,1)
	animation_player.play("unlocking")
	skill_icon_animation.texture = skill.lock.texture
	
func _input(event: InputEvent) -> void:
	can_move_skill_tree = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
	if can_move_skill_tree and inside_skill_tree and event is InputEventMouseMotion and not is_currently_unlocking_skill:
		is_moving = true
		center.position += event.relative
		center.position.x = clamp(center.position.x, 48, 360)
		center.position.y = clamp(center.position.y, 50, 312)
	else:
		is_moving = false


func _on_panel_container_mouse_entered() -> void:
	inside_skill_tree = true


func _on_panel_container_mouse_exited() -> void:
	if inside_skill_tree and not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		inside_skill_tree = false


func _on_animation_player_animation_finished(_anim_name: String) -> void:
	skill_icon_animation.texture = skill_icon.texture
	


func _on_skill_point_color_animation_finished(anim_name: String) -> void:
	if anim_name == "not_enough_points":
		skill_point_color_anim_player.play("rainbow")
