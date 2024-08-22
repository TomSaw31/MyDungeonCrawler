extends Node
## Used to register global signals


## Signal emitted when an item is collected
signal item_collected(_object: ItemData)
## Signal emitted when an item is added to the player's inventory
signal item_added_to_inventory(_item_amount)
## Signal emitted when an item is removed from the player's inventory
signal item_removed_from_inventory(_item_amount)
## Signal emitted when the number of skill points is modified
signal skill_point_modified()
## Signal emitted when the water level is changed
signal water_level_changed(_level: float)
## Signal triggered when equipped items are switched
signal equipped_items_switched(_items: Array[ItemData])
## Signal triggered when the inventory is opened / closed (used to stop process)
signal inventory_opened(_b: bool)
