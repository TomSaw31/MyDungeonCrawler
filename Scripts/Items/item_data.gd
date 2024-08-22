extends Resource
class_name ItemData
## Data of an item


## The name of the item
@export var item_name: String = ""

## The description of the item
@export var item_description: String = ""

## The inventory texture of the item
@export var texture: Texture2D = null

## The item scene to handle the item code
@export var item_scene: PackedScene = null

## The type of the item
@export var item_type: INVENTORY.ITEM_TYPE = INVENTORY.ITEM_TYPE.ITEM

## The damage / effect type
@export var damage_type: INVENTORY.ELEMENT_TYPES = INVENTORY.ELEMENT_TYPES.NORMAL

## The damage of the item if it is a weapon
@export var damage: int = 0

## The cooldown of the item if it is activable
@export var cooldown: float = 1

## The mana cost of the item
@export var mana_cost: float = 0

## Define if the item has limited uses
@export var limited_use: bool = false

## Number of uses if the item has a limited amount
@export var number_uses: int = 1
