extends Node
class_name State
## A state is used to define specific behavior of an entity (walking, flying, running, swimming, attacking, ...)

## Called when entering the state
func enter_state() -> void:
	pass

## Called when exiting the state
func exit_state() -> void:
	pass
	
## Called every frame when the state is active
func update(_delta: float) -> void:
	pass

## Called every physics frame when the state is active
func physics_update(_delta: float) -> void:
	pass

## Called when receiving an input and the state is active
func input_state(_event: InputEvent) -> void:
	pass
