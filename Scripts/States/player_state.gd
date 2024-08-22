extends State
class_name PlayerState
## A state specific to the player

## The player reference (owner of the state)
var player: Player

func _ready() -> void:
	player = owner
