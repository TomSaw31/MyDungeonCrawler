extends Control
## A notification to show what the player just obtained

## The item data of the obtained item notification
@export var item_data: ItemData = null
## The icon of the obtained item
@onready var texture_rect: TextureRect = $PanelContainer/CenterContainer/ItemIcon
## The name of the obtained item
@onready var item_name: Label = $PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/ItemName
## The description of the obtained item
@onready var item_description: Label = $PanelContainer/VBoxContainer/MarginContainer2/MarginContainer/VBoxContainer/ItemDescription
## The fade out sprite to make the item glow
@onready var fade_out: TextureRect = $PanelContainer/CenterContainer/fade_out
## Animation player for the transition
@onready var animation_player: AnimationPlayer = $AnimationPlayer
## Button to hide the notification
@onready var button: Button = $Button


func _ready() -> void:
	EVENTS.connect("item_collected", show_message)
	modulate.a = 0.

## Display the notification
func show_message(item: ItemData) -> void:
	item_data = item
	GAME.player.state_machine.set_state("InactiveState")
	animation_player.play("fade_in")
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	texture_rect.texture = item_data.texture
	item_name.text = item_data.item_name
	item_description.text = item_data.item_description.replace(". ","\n") + "\n"
	fade_out.modulate = get_color_from_type()


func _on_button_pressed() -> void:
	button.disabled = true
	animation_player.play("fade_out")
	GAME.player.state_machine.set_state(GAME.player.state_machine.previous_state)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_animation_player_animation_finished(anim_name: String) -> void:
	if anim_name == "fade_out":
		visible = false
	if anim_name == "fade_in":
		button.disabled = false

## Return the corresponding color according to the item type
func get_color_from_type() -> Color:
	if item_data == null:
		print("debug : item_data missing for color choice")
		return Color(0,0,0,1)
	match item_data.damage_type:
		INVENTORY.ELEMENT_TYPES.NORMAL:
			return Color(0.5,0.5,0.5,1)
		INVENTORY.ELEMENT_TYPES.FIRE:
			return Color(1, 0, 0, 1)
		INVENTORY.ELEMENT_TYPES.WATER:
			return Color(0.25, 0.25, 1, 1)
		INVENTORY.ELEMENT_TYPES.ROCK:
			return Color(1, 1, 0.5, 1)
		INVENTORY.ELEMENT_TYPES.PLANT:
			return Color(0, 1, 0, 1)
		INVENTORY.ELEMENT_TYPES.ICE:
			return Color(0.75, 0.75, 1, 1)
		INVENTORY.ELEMENT_TYPES.LIGHT:
			return Color(1, 1, 0.75, 1)
		INVENTORY.ELEMENT_TYPES.SHADOW:
			return Color(1, 0.5, 1, 1)
	return Color(0,0,0,1)
