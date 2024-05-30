class_name Player
extends CharacterBody2D


const SPEED : float = 300.0

const WAVES_MAX : int = 10

@export var wave_interval_time : float = 0.5
var wave_interval_timer : float= 0.0

# TODO : make the screen independant from the player, instantied by player
@export var s_v_mask : SVMask


@onready var occluders_inside: Area2D = %OccludersInside
@onready var collision_occluder_shape: CollisionShape2D = $OccludersInside/CollisionOccluderShape
@onready var screen: Sprite2D = %Screen
@onready var screen_mat : ShaderMaterial = screen.material as ShaderMaterial
@onready var sound_waves_node: Node2D = %SoundWavesNode


var waves : Array[SoundWave]
var active_waves : Array[SoundWave]
var wave_index : int = 0


func _ready() -> void:
	for i : int in sound_waves_node.get_child_count():
		waves.push_back(sound_waves_node.get_child(i))
	if waves.is_empty():
		push_error(" player.gd : put at least one wave under the designed component")
	collision_occluder_shape.shape.radius = waves[wave_index].radius

	screen.visible = true
	await RenderingServer.frame_post_draw
	update_tex(waves[wave_index].radius)


func _physics_process(_delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(Input.get_axis("left", "right"),Input.get_axis("up", "down")).normalized()
	if direction.x:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction.y:
		velocity.y = direction.y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()


func _process(delta: float) -> void:
	wave_interval_timer = max( wave_interval_timer - delta, 0.0)

	if Input.is_action_pressed("use") and is_zero_approx(wave_interval_timer):
		wave_interval_timer = wave_interval_time
		if active_waves.size() >= WAVES_MAX:
			print("too much waves")
		else:
			var new_wave : SoundWave = waves[wave_index].duplicate()
			wave_index = (wave_index +1) % waves.size()
			add_child(new_wave)
			active_waves.push_back(new_wave)
			var mask := await update_tex(new_wave.radius)   
			new_wave.finished.connect(_on_wave_finished)
			print(active_waves)
			new_wave.start(mask)
			# Prepare for next wave:
			collision_occluder_shape.shape.radius = waves[wave_index].radius

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

	if active_waves.is_empty():
		return
	# Update arrays to pass
	for i: int in active_waves.size():
		var wave : SoundWave = active_waves[i]

		wave_colors[i] = wave.color
		wave_radius[i] = wave.radius / (screen.get_rect().size.x * 0.5 * screen.scale.x) # Now scaled for the uv
		wave_outer_line_coefs[i] = wave.wave_outer_line_coef
		wave_origins[i] = (wave.origin - screen.global_position) / (screen.get_rect().size.x * 0.5 * screen.scale.x) # Define compared to the UV
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


func _on_wave_finished(_node: SoundWave) -> void:
	var idx := active_waves.find(_node)
	active_waves[idx].queue_free()
	active_waves.remove_at(idx)

@onready var debug_texture_rect = $"CanvasLayer/Debug texture rect"

func update_tex(_radius: float) -> Texture:
	if not s_v_mask :
		print("no sub viewport")
		return
	#collision_occluder_shape.shape.radius = _radius
	var tex : ViewportTexture = await s_v_mask.get_mask(global_position, _radius, occluders_inside.get_overlapping_bodies())
	var image: Image = tex.get_image()
	var new_tex := ImageTexture.create_from_image(image)
	print("image created")
	debug_texture_rect.texture = new_tex
	return new_tex

