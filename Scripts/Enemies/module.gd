extends Node3D
class_name Module
## Modules are enemies patterns

## Type of the movement pattern. MELEE is for melee attacks, RANGE is for projectiles based attack, STATUS is for status based (buffs, debuffs for the target), DEATH is for attacks after death.
enum MODULE_TYPE {MELEE, RANGE, STATUS, DEATH}

## The cooldown of the module
@export var cooldown: float = 1.

## The type of the module
@export var module_type: MODULE_TYPE = MODULE_TYPE.MELEE

## Define if the enemy can use the module
var can_be_used: bool = true

## Timer used for the cooldown of the module
var timer: Timer = null

func _ready() -> void:
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)


## Called to use the module
func use_module() -> void:
	can_be_used = false
	timer.start(cooldown)


func _on_timer_timeout() -> void:
	can_be_used = true
