class_name SoundWave
extends Node

signal finished(_node: SoundWave)

# TODO Make use of theses variables to alter teh wave in shader
@export var color := Color.WHITE
@export var travel_time : float = 1.0
@export var wave_size : float = 50

# TODO : Make the player use ths radius provided here (+ modifs related to state)
var radius : float

# Used for tweening the visible areas
var current_radius: float = 0
var inner_radius: float = 0

# Player provide it
var origin : Vector2
var mask : Texture


func _init(_radius: float, _origin: Vector2, _mask : Texture) -> void:
	radius = _radius
	origin = _origin
	mask = _mask

func start() -> void:
	var tween : Tween = create_tween()
	tween.tween_property(self, "current_radius", 1.0, travel_time).from(0.0)
	tween.tween_property(self, "inner_radius", 1.0, travel_time ).from(0.0)
	tween.tween_interval(0.2)
	tween.tween_callback(_finished)

func _finished() -> void:
	finished.emit(self)
