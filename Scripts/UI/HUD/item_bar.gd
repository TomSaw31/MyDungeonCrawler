extends PanelContainer
class_name ItemBar
## Contains the items icon to display them in the HUD

## Contains all icons
@onready var icon_tab: Array[TextureRect] = [$HBoxContainer/Item0,$HBoxContainer/Item1,$HBoxContainer/Item2,$HBoxContainer/Item3,$HBoxContainer/Item4]
## The default color of the unselected items
const UNSELECTED_COLOR: Color = Color(0.5,0.5,0.5,0.5)
## The default icon texture when the slot is empty
const DEFAULT_TEXTURE: Texture2D = preload("res://Assets/Textures/UI/HUD/Bars/item_bar_slot.png")

func _ready() -> void:
	EVENTS.connect("equipped_items_switched", update_item_bar)

## Update one of the item icons in the item bar
func update_item_bar(items: Array[ItemData]) -> void:
	for i in range(5):
		if items[i] == null:
			icon_tab[i].texture = DEFAULT_TEXTURE
		else:
			icon_tab[i].texture = items[i].texture


## Update visually wich item slot is currently used
func update_selected(index: int) -> void:
	for icon in icon_tab:
		icon.modulate = UNSELECTED_COLOR
	icon_tab[index].modulate = Color(1,1,1,1)
