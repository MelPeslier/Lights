class_name SWWave
extends Node2D

signal finished(_node: SWWave)

@export var travel_time : float = 1.0

# 7 parameters for the shader :
@export_color_no_alpha var color := Color.WHITE
@export var radius : float = 512
@export var wave_outer_line_coef : float = 0.05
var origin : Vector2
var current_radius: float = 0
var inner_radius: float = 0
var mask : Texture

# TODO : Add the song that instantiate itself once ready

func _ready() -> void:
	origin = global_position
	

func start(_mask : Texture) -> void:
	var tween : Tween = create_tween()
	mask = _mask
	tween.tween_property(self, "current_radius", 1.0, travel_time).from(0.0)
	tween.tween_property(self, "inner_radius", 1.0, travel_time ).from(0.0)
	tween.tween_callback(_finished)

# Then
func _finished() -> void:
	finished.emit(self)

