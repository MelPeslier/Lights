class_name Ground
extends StaticBody2D

@onready var light_occluder_2d: LightOccluder2D = %LightOccluder2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light_occluder_2d.visible = false

