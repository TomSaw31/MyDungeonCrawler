extends TextureButton
class_name SkillNode
## Skill slot representing an unlockable skill

## Lines connecting the skills
@onready var back_lines: Array[Line2D] = [$LinkBackground/backline1,$LinkBackground/backline2,$LinkBackground/backline3]
## Lines used as an outline
@onready var outlines: Array[Line2D] = [$LinkOutlines/outline1,$LinkOutlines/outline2]
## Lines used for the colors
@onready var color_line: Line2D = $ColorLinks/LineColor1
## The texture of the lock
@onready var lock: TextureRect = $Lock
## Create animation when hovering
@onready var hovering_animation_player: AnimationPlayer = $HoveringAnimationPlayer
## Create animation when unlocking
@onready var unlocking_animation_player: AnimationPlayer = $UnlockingAnimationPlayer
## Create a filling animation when the color between two unlocked skills changed
@onready var color_filling_animation_player: AnimationPlayer = $ColorFillingAnimationPlayer
## The progress bar use to unlock the skill
@onready var texture_progress_bar: TextureProgressBar = $Control/TextureProgressBar




## The name of the skill
@export var skill_name: String = ""
## The description of the skill
@export var skill_description: String = ""
## The type of skill (DAMAGE, CRITICAL_HIT, RESISTANCE, SPEED, MANA, HEALTH)
@export var skill_type: String = ""
## The level of the skill
@export var skill_level: int = 1
## The button used to display which update is unlocked based on the type of the skill
@export var unlocked_skill_button: TextureButton = null
## The skill node used to link indirect skills
@export var neighbour1: SkillNode = null
## The other skill node used to link indirect skills
@export var neighbour2: SkillNode = null
## The dictionary used to match skill types to color
var skill_colors: Dictionary = {"damage": Color(1, 0, 0), "mana" :Color(0, 0, 1), "resistance": Color(1, 0.5, 0),"health": Color(0, 1, 0),"critical_hit": Color(1, 0, 1),"speed": Color(1, 1, 0)}
## Used for the varying efffect of the color bar
var variying: float = 0
## Define if the skill is unlocked
var unlocked: bool = false
## Define if the skill can be unlocked, meaning that the previous same type skill has been unlocked
var can_be_unlocked: bool = false
## Tell if the skill is in focus
var in_focus: bool = false
## Determine if it is the initialization phase
var init: bool = false
## Determine if the init phase is done
var init_done: bool = false
## Determine if the skill is finished to stop the process
var finished: bool = false

func _ready() -> void:
	set_process(false)
	EVENTS.connect("inventory_opened", inventory_change_process_mode)
	if skill_name == "default":
		var skills: Array[Node] = get_children()
		for skill in skills:
			if skill is SkillNode:
				skill.disabled = false
		self_modulate = Color(1,1,1,1)
		unlocked = true
	else:
		match skill_level:
			1: lock.texture = preload("res://Assets/Textures/UI/HUD/Skills/lock_1.png")
			2: lock.texture = preload("res://Assets/Textures/UI/HUD/Skills/lock_2.png")
			3: lock.texture = preload("res://Assets/Textures/UI/HUD/Skills/lock_3.png")
	$Background/SkillIcon.texture = texture_normal

	if get_parent() is SkillNode:
		back_lines[0].add_point(get_parent().global_position + size/2 - back_lines[0].global_position)
		outlines[0].add_point(get_parent().global_position + size/2 - outlines[0].global_position)
		if neighbour1 != null:
			outlines[1].add_point(neighbour1.global_position + size/2 - outlines[1].global_position)
			back_lines[1].add_point(neighbour1.global_position + size/2 - back_lines[1].global_position)
			back_lines[2].add_point(neighbour1.global_position + size/2 - back_lines[2].global_position)
	if skill_name == "default":
		for child in get_children():
			if child is SkillNode:
				child.update_color_unlockable()

## Switch between process mode depending of the inventory is open or closed
func inventory_change_process_mode(b: bool) -> void:
	if b and not finished and not skill_name == "default":
		set_process(true)
	if not b:
		set_process(false)

## Update the color when a skill is the next to be unlocked
func update_color_unlockable() -> void:
	init = true
	texture_progress_bar.modulate = skill_colors[skill_type]
	texture_progress_bar.value = 0
	can_be_unlocked = true
	color_line.add_point(get_parent().color_line.global_position - color_line.global_position)
	color_line.set_point_position(0,get_parent().color_line.global_position - color_line.global_position)
	color_line.default_color = skill_colors[skill_type]

func _process(delta: float) -> void:
	variying += delta
	if not init and in_focus and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if get_parent() is SkillNode and not get_parent().unlocked:
			get_parent().unlocking_animation_player.play("locked")
	if init:
		color_line.set_point_position(0,lerp(color_line.get_point_position(0),(get_parent().color_line.global_position - color_line.global_position) * (0.5 + sin(variying) / 15),delta * 3))
		if color_line.get_point_position(0).distance_to((get_parent().color_line.global_position - color_line.global_position) * (0.5 + sin(variying) /15)) < 5:
			init_done = true
		if color_line.get_point_position(0).distance_to((get_parent().color_line.global_position - color_line.global_position) * (0.5 + sin(variying) / 15)) < 0.25:
			init = false
	if init_done:
		if not unlocked:
			if not init:
				color_line.set_point_position(0,(get_parent().color_line.global_position - color_line.global_position) * (0.5 + sin(variying) / 15))
			if in_focus and can_be_unlocked:
				if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not GAME.player.hud.skill_tree.is_moving:
					if INVENTORY.skill_points >= skill_level:
						texture_progress_bar.value += delta * 1.5
						if texture_progress_bar.value >= texture_progress_bar.max_value:
							GAME.player.hud.skill_tree.is_currently_unlocking_skill = true
							unlock()
					else:
						GAME.player.hud.skill_tree.skill_point_color_anim_player.play("not_enough_points")
						texture_progress_bar.value = 0
						GAME.player.hud.skill_tree.is_currently_unlocking_skill = false
				if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
					texture_progress_bar.value = 0
					GAME.player.hud.skill_tree.is_currently_unlocking_skill = false
		else:
			color_line.set_point_position(0,lerp(color_line.get_point_position(0),Vector2(0,0),delta * 3))
			if color_line.get_point_position(0).distance_to(Vector2(0,0)) <= 1:
				finished = true
				set_process(false)

## Unlock the skill
func unlock() -> void:
	if INVENTORY.skill_points > 0 and not unlocked:
		if neighbour1.unlocked:
			color_filling_animation_player.play("color_fill")
			back_lines[2].gradient.set_color(0,skill_colors[skill_type])
			back_lines[2].gradient.set_color(1,skill_colors[neighbour1.skill_type])
		if neighbour2.unlocked:
			neighbour2.color_filling_animation_player.play("color_fill")
			neighbour2.back_lines[2].gradient.set_color(0,skill_colors[neighbour2.skill_type])
			neighbour2.back_lines[2].gradient.set_color(1,skill_colors[skill_type])

		unlocked = true
		texture_progress_bar.value = 0
		unlocking_animation_player.play("unlocking")
		GAME.player.hud.skill_tree.play_cost_animation(self)
		GAME.player.hud.skill_tree.update_infos(self)
		INVENTORY.update_skill_points(INVENTORY.skill_points - skill_level)
		self_modulate = Color(1,1,1,1)
		var skills: Array[Node] = get_children()
		
		for skill in skills:
			if skill is SkillNode:
				skill.disabled = false
		back_lines[0].set_point_position(1,get_parent().global_position + size/2 - back_lines[0].global_position)
		INVENTORY.update_skills(skill_type, skill_level, skill_type)
		unlocked_skill_button.update_unlocked_skill(skill_name, skill_description, skill_level,texture_normal)
		$Background.texture = preload("res://Assets/Textures/UI/HUD/Skills/skill_slot.png")
		$Background.self_modulate = skill_colors[skill_type]
		for child in get_children():
			if child is SkillNode:
				child.update_color_unlockable()
				child.variying = variying
		can_be_unlocked = false
		$Timer.start(3)
		GAME.player.hud.skill_tree.is_currently_unlocking_skill = false
		
func _on_focus_entered() -> void:
	if skill_name != "default":
		select()

func _on_mouse_entered() -> void:
	if skill_name != "default":
		select()
		
## Set the information and play animations when in focus
func select() -> void:
	if unlocked:
		GAME.player.hud.skill_tree.update_infos(self)
	else:
		GAME.player.hud.skill_tree.update_infos(self)
	if not in_focus:
		hovering_animation_player.play("hovering")
	in_focus = true

## Called when the skill is exiting focus
func unselect() -> void:
	texture_progress_bar.value = 0
	if in_focus:
		hovering_animation_player.play_backwards("hovering")
	in_focus = false

func _on_focus_exited() -> void:
	if skill_name != "default":
		unselect()

func _on_mouse_exited() -> void:
	if skill_name != "default":
		unselect()


func _on_timer_timeout():
	finished = true
	set_process(false)
