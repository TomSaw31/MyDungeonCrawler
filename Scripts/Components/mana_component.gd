extends Node3D
class_name ManaComponent
## Component that handles the mana stat



## Mana value
@export var mana: float = 100
## Max Mana value
@export var default_max_mana: float = 100
## Mana regen speed
@export var mana_regen_speed: float = 7.5
## The time that need to be waited for the mana to regen
@export var mana_regeneration: float = 2.5
## The timer used for the regen
@onready var mana_regen_timer: Timer = $ManaRegeneration
## Variable used to keep track on the real mana max after the bonus applied
var max_mana: float = 0

func _ready() -> void:
	set_process(false)
	max_mana = default_max_mana

## Update the mana contained in the component according to the cost
func update_mana(cost: float = 0) -> void:
	mana = clamp(mana - cost, 0, max_mana)
	if mana < 1:
		mana = 0
	if owner is Player:
		owner.hud.bars.update_mana(owner.mana_component.mana, owner.mana_component.max_mana)
		mana_regen_timer.start(mana_regeneration)
		set_process(false)

## Return if the component contains enough mana	
func has_enough_mana(cost: float) -> bool:
	return mana >= cost

func _process(delta: float) -> void:
	mana = clamp(mana + delta * mana_regen_speed, 0, max_mana)
	if owner is Player:
		owner.hud.bars.update_mana(owner.mana_component.mana, owner.mana_component.max_mana)
		
	if mana >= max_mana:
		mana = max_mana
		set_process(false)

func _on_mana_regeneration_timeout() -> void:
	if mana < max_mana:
		set_process(true)
		
## Update the mana max after bonuses (add before mult) 
func update_mana_max(add: Array[float], mult: Array[float]) -> void:
	max_mana = default_max_mana
	for e in add:
		max_mana += e
	for e in mult:
		max_mana *= e
	if mana < max_mana:
		mana_regen_timer.start(mana_regeneration)
