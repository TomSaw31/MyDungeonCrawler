extends HBoxContainer
## The interaction with the info and circular progress bar

## The offset of the text on the left side to blend with the button indication
const LEFT_OFFSET: String = "             "
## The offset of the text on the right side
const RIGHT_OFFSET: String = "   "
## The progress bar
@onready var progress_bar: TextureProgressBar = $PanelContainer/ProgressBar
## The label indicating what to do
@onready var label: Label = $MarginContainer/CenterContainer/Label
## The timer for the remaining interaction time
@onready var timer: Timer = $Timer
## The key indication of the interaction
@onready var key_text: Label = $PanelContainer/KeyText
## The animation player for the fade  in and fade out animations
@onready var animation_player: AnimationPlayer = $AnimationPlayer

## TODO add constant opacity

## The interaction time
var interaction_time: float = 1
## The interaction component of the actor
var interaction_component: InteractionComponent = null
### Variable to search the key bind only once
var has_searched_key: bool = false

## Reset the interaction (hide, reset value and timer)
func reset() -> void:
	set_process(false)
	progress_bar.value = 0
	timer.stop()

## Hide and reset the interaction
func hide_interaction() -> void:
	reset()
	animation_player.play("fade")
	has_searched_key = false

## Show the interaction
func show_interaction(component: InteractionComponent) -> void:
	if not has_searched_key:
		key_text.text = GAME.get_input_key_from_action("interaction")
		has_searched_key = true
		animation_player.play("fade_in")
	interaction_component = component
	visible = true
	label.text = LEFT_OFFSET + component.info + RIGHT_OFFSET
	interaction_time = component.time

## Start the interaction if not started
func start_interaction() -> void:
	if interaction_component.instant:
		_interact()
	elif timer.is_stopped() and interaction_component.used == false:
		timer.start(interaction_time)
		set_process(true)

func _process(_delta: float) -> void:
	progress_bar.value = 1 - timer.time_left / interaction_time

func _on_timer_timeout() -> void:
	reset()
	if interaction_component != null and interaction_component.one_time == true:
		interaction_component.used = true
	_interact()

## Start the interaction for the player when the interaction is ended
func _interact() -> void:
	# TODO ADD SOUND
	animation_player.play("fade")
	GAME.player.interact()



func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade":
		visible = false
