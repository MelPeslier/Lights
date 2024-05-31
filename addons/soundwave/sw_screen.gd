@tool
class_name SWScreen
extends Sprite2D

const BASE_TEXTURE = preload("res://addons/soundwave/art/black.png")
const BASE_MATERIAL = preload("res://addons/soundwave/sw_screen.tres")

	# *** WARNING ***
# Changing this parameters means changing it into the shader too (+updating the number of sampler2D)
const WAVES_MAX : int = 10
# ---------------

@export var node_to_follow : Node2D :
	set(_node):
		node_to_follow = _node
		if Engine.is_editor_hint():
			update_configuration_warnings()
			return
		if node_to_follow:
			set_process(true)

var screen_mat : ShaderMaterial
var active_waves : Array[SWWave]

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if not node_to_follow:
		warnings.push_back("Don't forget to set a node to follow,\n\teither via code or the export property")
	return warnings


func _ready() -> void:
	if Engine.is_editor_hint(): 
		set_process(false)
		return
	# TODO Dynamically change the size based on the active camera and the base resolution
	SWSignal.sw_screen_ready.emit(self)
	node_to_follow = node_to_follow
	visible = true
	texture = BASE_TEXTURE
	var new_scale : float = 7.5
	scale = Vector2(new_scale, new_scale)
	material = BASE_MATERIAL
	screen_mat = material as ShaderMaterial


func _process(_delta: float) -> void:
	global_position = node_to_follow.global_position
	# Update active waves each frame
	var wave_colors : Array[Color] = []
	wave_colors.resize(WAVES_MAX)

	var wave_radius : Array[float] = []
	wave_radius.resize(WAVES_MAX)

	var wave_outer_line_coefs : Array[float] = []
	wave_outer_line_coefs.resize(WAVES_MAX)

	var wave_origins : Array[Vector2] = []
	wave_origins.resize(WAVES_MAX)

	var wave_current_radius : Array[float] = []
	wave_current_radius.resize(WAVES_MAX)

	var wave_inner_radius : Array[float] = []
	wave_inner_radius.resize(WAVES_MAX)

	var wave_masks : Array[Texture] = []
	wave_masks.resize(WAVES_MAX)

	# Update arrays to pass
	for i: int in active_waves.size():
		var wave : SWWave = active_waves[i]

		wave_colors[i] = wave.color
		wave_radius[i] = wave.radius / (get_rect().size.x * 0.5 * scale.x) # Now scaled for the uv
		wave_outer_line_coefs[i] = wave.wave_outer_line_coef
		wave_origins[i] = (wave.origin - global_position) / (get_rect().size.x * 0.5 * scale.x) # Define compared to the UV
		wave_current_radius[i] = wave.current_radius
		wave_inner_radius[i] = wave.inner_radius
		wave_masks[i] = wave.mask
		
		var mask_name : String = "wave_mask_0" + str(i+1)
		screen_mat.set_shader_parameter(mask_name, wave_masks[i])

# Pass arrays
	screen_mat.set_shader_parameter("wave_colors", wave_colors)
	screen_mat.set_shader_parameter("wave_radius", wave_radius)
	screen_mat.set_shader_parameter("wave_outer_line_coefs", wave_outer_line_coefs)
	screen_mat.set_shader_parameter("wave_origins", wave_origins)
	screen_mat.set_shader_parameter("wave_current_radius", wave_current_radius)
	screen_mat.set_shader_parameter("wave_inner_radius", wave_inner_radius)
	screen_mat.set_shader_parameter("actual_array_size", active_waves.size())


#region Functions
func can_add_wave() -> bool:
	return active_waves.size() < WAVES_MAX

func add_wave(_new_wave : SWWave) -> void:
	_new_wave.finished.connect(_on_wave_finished)
	active_waves.push_back(_new_wave)

func _on_wave_finished(_node: SWWave) -> void:
	var idx := active_waves.find(_node)
	active_waves[idx].queue_free()
	active_waves.remove_at(idx)
#endregion
