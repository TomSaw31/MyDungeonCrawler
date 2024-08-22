extends Node
class_name StateMachine

## The state used after the initialisation of the state machine
@export var initial_state: State
## The current state used by the state maching
var current_state: State = null
## The previous state that was uysed by the machine
var previous_state: State = null
## Signal fired when the active state is changed
signal state_changed

func  _ready() -> void:
	set_state(initial_state)

## Modify the current active states. The old one is exited and the new one is entered.
func set_state(state) -> void:
	if state is String:
		state = get_node_or_null(state)
	if state == current_state:
		return
	if current_state != null:
		current_state.exit_state()
	previous_state = current_state
	current_state = state
	emit_signal("state_changed")
	current_state.enter_state()

## Return the active state node
func get_state() -> Node : return current_state

## Return the active state name. Returns an empty string if NULL
func get_state_name() -> String: 
	if current_state == null:
		return ""
	return current_state.name

## Return the previous active state
func get_previous_state() -> Node : return previous_state

## Return the previous active state name. Returns an empty string if NULL
func get_previous_state_name() -> String:
	if previous_state == null:
		return ""
	return previous_state.name

func _unhandled_input(event: InputEvent) -> void:
	if current_state != null:
		current_state.input_state(event)

func _physics_process(delta: float) -> void:
	if current_state!=null:
		current_state.physics_update(delta)
		
func _process(delta: float) -> void:
	if current_state!=null:
		current_state.update(delta)
