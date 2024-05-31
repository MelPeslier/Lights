@tool
class_name SWManager
extends Node2D

var sw_screen: SWScreen
var sw_mask_baker : SWMaskBaker

var occluder_detector : Area2D
var collision_shape : CollisionShape2D

var wave_index : int = 0

func _init() -> void:
	if not Engine.is_editor_hint(): return
	update_configuration_warnings()


func _notification(what: int) -> void:
	if not Engine.is_editor_hint(): return
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			update_configuration_warnings()


func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if get_child_count() == 0:
		warnings.push_back("Must have at least one SWWave as a child")
	else:
		for item in get_children():
			if not item is SWWave:
				warnings.push_back("Must only contain SWWave nodes type as childs")
				break
	return warnings


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	SWSignal.sw_mask_baker_ready.connect(_on_sw_mask_baker_ready)
	SWSignal.sw_screen_ready.connect(_on_sw_screen_ready)
	
	occluder_detector = Area2D.new()
	occluder_detector.collision_layer = 0
	occluder_detector.collision_mask = 2 # TODO : avec le plugin, rentre cette variable centralisée
	add_sibling.call_deferred(occluder_detector, true)
	collision_shape = CollisionShape2D.new()
	occluder_detector.add_child(collision_shape)
	collision_shape.shape = CircleShape2D.new()
	collision_shape.shape.radius = get_child(wave_index).radius

# Call this once you want to start a wave, more than SWScreen WAVE_MAX already used and it won't start it
func ask_for_next_wave() -> bool:
	if not sw_screen.can_add_wave():
		print("Too much waves already in the shader, consider spacing them or changing the max number of wave")
		return false
	
	var new_wave : SWWave = get_child(wave_index).duplicate()
	wave_index = (wave_index + 1) % get_child_count() # Ignore occluder_detector
	add_child(new_wave)
	var mask := await sw_mask_baker.get_mask(global_position, new_wave.radius, occluder_detector.get_overlapping_bodies())
	new_wave.start(mask)
	sw_screen.add_wave(new_wave)
	# Prepare for next wave:
	collision_shape.shape.radius = get_child(wave_index).radius
	return true


# Signals
func _on_sw_mask_baker_ready(_sw_mask_baker : SWMaskBaker) -> void:
	sw_mask_baker = _sw_mask_baker

func _on_sw_screen_ready(_sw_screen : SWScreen) -> void:
	sw_screen = _sw_screen
