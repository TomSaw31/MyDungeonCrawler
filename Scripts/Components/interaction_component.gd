extends Node3D
class_name InteractionComponent
## Component that enables simple interactions



## Define if the interaction is instant (no duration)
@export var instant: bool =  false

## Duration of the interaction
@export var time: float = 1

## Define the information relative to the interaction
@export var info: String = "Interact"

## Define if the interaction can be done more than one time
@export var one_time: bool = true


## Used to know if the interaction has already been done
var used: bool = false
