extends Node3D
class_name ModulesMaster
## Used to handle the different modules of the nemy

## The list of all modules that the enemy will use
@export var modules: Array[Module] = []

## Cooldown used to determine when the enemy should use the modules
@export var cooldown: float = 3

## Type of the movement pattern. MELEE is for melee attacks, RANGE is for projectiles based attack, STATUS is for status based (buffs, debuffs for the target), DEATH is for attacks after death.
enum MODULE_TYPE {MELEE, RANGE, HEAL, DEATH}

## Timer used as cooldown for the use of the modules
@onready var timer: Timer = $Timer

## Define if it is activated
var is_active: bool = true

func _ready() -> void:
	for child in get_children():
		if child is Module:
			modules.append(child)
	timer.start(cooldown + randf_range(0,2))


## Return a list of all the enemy's modules of a certain type
func get_modules_of_type(module_type: MODULE_TYPE) -> Array[Module]:
	'''Return all active modules of the specified type'''
	var active_modules: Array[Module] = []
	for module in modules:
		if module.can_be_used and module.module_type == module_type:
			active_modules.append(module)
	return active_modules
	

func _on_timer_timeout() -> void:
	if is_active == true:
		var modules_list: Array[Module] = get_modules_of_type(MODULE_TYPE.MELEE)
		if len(modules_list) > 0:
			modules_list.pick_random().use_module()
		timer.start(cooldown + randf_range(0,2))
		
