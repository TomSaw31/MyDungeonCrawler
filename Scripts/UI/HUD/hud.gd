extends Control
class_name HUD

## Used to show and hide the whole inventory
@onready var margin_container = $MarginContainer
## The fps counter
@onready var fps_counter: Label = $FPS
## The tab container (WEAPONS, ITEMS, SKILLS, SETTINGS)
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
## The inventory containing the weapons
@onready var inventory =$MarginContainer/VBoxContainer/TabContainer/Inventory
## The skill tree in the inventory
@onready var skill_tree = $MarginContainer/VBoxContainer/TabContainer/SkillTree
## The bars of stats of the HUD (Health, Mana, ...)
@onready var bars: Bars = $Bars/Bars
## The interaction
@onready var interaction = $Interaction
## The bar containing the item equipped
@onready var item_bar: ItemBar = $ItemBar

func _process(_delta: float) -> void:
	fps_counter.text = str(Engine.get_frames_per_second())

## Refresh inventory
func refresh_inventory() -> void:
	inventory.refresh()

## Refresh and show the inventory and unlock mouse
func show_inventory() -> void:
	refresh_inventory()
	margin_container.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if tab_container.current_tab == 0:
		inventory.refresh_item_list()

## Hide the inveotry and lock mouse
func hide_inventory() -> void:
	margin_container.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Switch between inventory tabs
func switch_menu() -> void:
	tab_container.current_tab = (tab_container.current_tab + 1) % 2

## Start the interaction
func start_interaction() -> void:
	interaction.start_interaction()

## Reset the interaction
func reset_interaction() -> void:
	interaction.reset()

## Show the interaction
func show_interaction(component: InteractionComponent) -> void:
	if component.one_time != true or (component.one_time == true and component.used == false):
		interaction.show_interaction(component)
	else:
		hide_interaction()

## Hide the interaction
func hide_interaction() -> void:
	interaction.hide_interaction()

## Show a shader representing underwater
func head_underwater(b: bool) -> void:
	$UnderwaterShader.visible = b

## Update the equipped items in the item bar
func update_items_equipped(items: Array[ItemData]) -> void:
	item_bar.update_item_bar(items)

## Switch between items in the item bar
func switch_item(index: int) -> void:
	item_bar.update_selected(index)

func _on_weapons_button_pressed() -> void:
	tab_container.current_tab = 0
	inventory.refresh_item_list()
	


func _on_skills_button_pressed() -> void:
	tab_container.current_tab = 1
