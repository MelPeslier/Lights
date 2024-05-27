class_name Player
extends CharacterBody2D


const SPEED = 300.0

@export var wave_length : float = 900 :
	set(_new):
		wave_length = _new
		if is_inside_tree():
			collision_occluder_shape.shape.size = Vector2.ONE * wave_length


@export var sound_waves : Sprite2D

@export var s_v_mask : SVMask



@onready var occluders_inside: Area2D = %OccludersInside
@onready var wave_mask_debug: TextureRect = %WaveMaskDebug
@onready var collision_occluder_shape: CollisionShape2D = $OccludersInside/CollisionOccluderShape
@onready var image_debug: TextureRect = %ImageDebug
@onready var screen: Sprite2D = %Screen
@onready var screen_mat : ShaderMaterial = screen.material as ShaderMaterial

@onready var screen_tex_debug: TextureRect = %ScreenTexDebug
@onready var screen_tex_debug_mat : ShaderMaterial = screen_tex_debug.material as ShaderMaterial


var waves : Array[SoundWave]
var test_wave : SoundWave

func _ready() -> void:
	wave_length = wave_length
	print(get_viewport_rect().size)
	await RenderingServer.frame_post_draw
	update_tex()

func _physics_process(delta: float) -> void:
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

	if Input.is_action_just_pressed("use"):
		var mask := await update_tex()
		var wave := SoundWave.new(wave_length, global_position, mask)
		add_child(wave)
		waves.push_back(wave)
		wave.finished.connect(_on_wave_finished)

		test_wave = wave
		test_wave.start()

	# Update current data between 0 and 1

	var wave_origin := Vector2.ZERO
	var wave_radius : float = 0.0
	var wave_current_radius : float = 0.0
	var wave_inner_radius : float = 0.0
	var mask : Texture = null

	var wave_origin_debug := Vector2.ZERO
	var wave_radius_debug :float = 0.0

	if test_wave:
		# Center the 'global pos' of the screen, so it maps wiht the uv
		wave_origin = (test_wave.origin - screen.global_position) / (screen.get_rect().size.x * 0.5 * screen.scale.x) # Define compared to the UV
		wave_radius = test_wave.radius / (screen.get_rect().size.x * screen.scale.x)

		wave_current_radius = test_wave.current_radius
		wave_inner_radius = test_wave.inner_radius
		mask = test_wave.mask
		#1.77778 1920/1080
		#0.5625 1080/1920
		#0.46875 900/1920
		#radius / screen.x
		#2.86458 5500/1920
		1 * 0.46875
		wave_origin_debug = (test_wave.origin - screen.global_position) / screen_tex_debug.size
		wave_radius_debug = test_wave.radius / screen.get_rect().size.x * screen.scale.x

	screen_mat.set_shader_parameter("wave_origin", wave_origin)
	screen_mat.set_shader_parameter("wave_radius", wave_radius)
	screen_mat.set_shader_parameter("wave_current_radius", wave_current_radius)
	screen_mat.set_shader_parameter("wave_inner_radius", wave_inner_radius)
	screen_mat.set_shader_parameter("mask", mask)

	screen_tex_debug_mat.set_shader_parameter("wave_origin", wave_origin)
	screen_tex_debug_mat.set_shader_parameter("wave_radius", wave_radius)
	screen_tex_debug_mat.set_shader_parameter("wave_current_radius", wave_current_radius)
	screen_tex_debug_mat.set_shader_parameter("wave_inner_radius", wave_inner_radius)
	screen_tex_debug_mat.set_shader_parameter("mask", mask)


func _on_wave_finished(_node: SoundWave) -> void:
	var idx := waves.find(_node)
	waves[idx].queue_free()
	waves.remove_at(idx)
	if waves.is_empty():
		test_wave = null
		return
	test_wave = waves[waves.size()-1]


func update_tex() -> Texture:
	if not s_v_mask :
		print("no sub viewport")
		return
	var screen_size : float = screen.get_rect().size.x * screen.scale.x
	var tex : ViewportTexture = await s_v_mask.get_mask(global_position, screen_size, occluders_inside.get_overlapping_bodies())
	wave_mask_debug.texture = tex

	var image: Image = tex.get_image()
	var new_tex := ImageTexture.create_from_image(image)
	image_debug.texture = new_tex
	return new_tex

