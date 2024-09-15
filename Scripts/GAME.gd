extends Node
## Register the important data of the game

## Time scale used in game
var time_scale: float = 1

## The main player of the game
var player: Player

## The player spawning location
var spawning_position: Vector3 = Vector3(0,0,0)

## Keep track if the player is using a controller or a keyboard based on the last input
var is_using_keyboard: bool = true

func _input(event: InputEvent) -> void:
	if is_using_keyboard and (event is InputEventJoypadButton or event is InputEventJoypadMotion):
			is_using_keyboard = false
	elif event is InputEventMouseButton or event is InputEventKey:
			is_using_keyboard = true

## Take an action name and return the key name associated to it
func get_input_key_from_action(action: String) -> String:
	var text: String = ""
	for event in InputMap.action_get_events(action):
		if is_using_keyboard:
			if event is InputEventKey:
				var key: Key = event.keycode
				if key == KEY_NONE:
					key = DisplayServer.keyboard_get_label_from_physical(event.physical_keycode)
				text = OS.get_keycode_string(key)
				return text
		else:
			if event is InputEventJoypadButton:
				# TODO change the name of button (button nintendo != button xbox)
				match event.button_index:
					JOY_BUTTON_A:
						text = "A"
					JOY_BUTTON_B:
						text = "B"
					JOY_BUTTON_X:
						text = "X"
					JOY_BUTTON_Y:
						text = "Y"
				return text
			elif event is InputEventJoypadMotion:
				match event.axis:
					JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
						text = "Left Joystick"
					JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
						text = "Right Joystick"
				return text
	return text
