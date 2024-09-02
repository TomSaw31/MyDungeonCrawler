extends LineEdit
class_name CommandLine
## Allows to use commands

## COMMANDS

## [free -> enter free camera mode]
## [roomupdate -> switch between active room update mode]
## [give XXX -> give the item name XXX to the player]
## [health X -> set the player health to X (X <= max)]
## [mana X -> set the player mana to X (X <= max)]
## [water X -> update the water level]

## Stores the entered commands
var entered_commands: Array[String] = []
## Stores the index of the entered command
var index: int = -1
## Used to know if the active rooms are constantly updated
var constant_room_update: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("command"):
		toggle_command();
	if event.is_action_pressed("ui_up"):
		index += 1
		if len(entered_commands) > index:
			text = entered_commands[len(entered_commands) - index - 1]
	if event.is_action_pressed("ui_down"):
		if index > 0:
			index -= 1
			text = entered_commands[len(entered_commands) - index - 1]
		else:
			index -= 1
			text = ""

## Toggle the command line between the active and inactive state
func toggle_command() -> void:
	visible = not visible
	if visible:
		GAME.player.state_machine.set_state("InactiveState")
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		grab_focus()
	else:
		GAME.player.state_machine.set_state(GAME.player.state_machine.previous_state)
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

func _process(_delta: float) -> void:
	if constant_room_update:
		EVENTS.emit_signal("player_active_room_changed")

func _on_text_submitted(new_text: String) -> void:
	var command: PackedStringArray = new_text.split(" ")
	toggle_command()
	if len(command) == 1:
		if command[0] == "free":
			if GAME.player.state_machine.get_state_name() != "FreeCameraState":
				GAME.player.state_machine.set_state("FreeCameraState")
			else:
				GAME.player.state_machine.set_state("DefaultState")
		if command[0] == "roomupdate":
			constant_room_update = not constant_room_update
	elif len(command) == 2:
		if command[0] == "water" and command[1].is_valid_float():
			EVENTS.emit_signal("water_level_changed", float(command[1]))
		if command[0] == "give":
			for item in LOOT_TABLES.all_item_resource_list:
				if item.item_name.to_lower().replace(" ","") == command[1].to_lower():
					EVENTS.item_collected.emit(item)
		if command[0] == "health" and command[1].is_valid_float():
			if GAME.player.health_component.max_health >= float(command[1]):
				GAME.player.health_component.health = float(command[1])
				GAME.player.health_component.update_health()
		if command[0] == "mana" and command[1].is_valid_float():
			if GAME.player.mana_component.max_mana >= float(command[1]):
				GAME.player.mana_component.mana = float(command[1])
				GAME.player.mana_component.update_mana()
	if len(entered_commands) > 10:
		entered_commands.remove_at(0)
	entered_commands.append(new_text)
	index = -1
	text = ""
