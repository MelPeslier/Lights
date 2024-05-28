class_name Player
extends CharacterBody2D


const SPEED = 300.0

@export var wave_length : float = 900 :
	set(_new):
		wave_length = _new
		if is_inside_tree():
			collision_occluder_shape.shape.radius = wave_length

# TODO : Instantiate via code + only copy in it the light occluders at moment T nothing else
@export var s_v_mask : SVMask

@onready var occluders_inside: Area2D = %OccludersInside
@onready var collision_occluder_shape: CollisionShape2D = $OccludersInside/CollisionOccluderShape

@onready var screen: Sprite2D = %Screen
@onready var screen_mat : ShaderMaterial = screen.material as ShaderMaterial

@onready var wave_mask_debug: TextureRect = %WaveMaskDebug
@onready var image_debug: TextureRect = %ImageDebug

var waves : Array[SoundWave]
var test_wave : SoundWave

func _ready() -> void:
	screen.visible = true
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
		wave_radius = test_wave.radius / (screen.get_rect().size.x * 0.5 * screen.scale.x) # Now scaled for the uv
		#512.0 / 1920.0 = 0.266667
		#512.0 * 2.0 / 1920.0 = 0.533333
		#256*2.0 / 1920.0 = 0.266667

		wave_current_radius = test_wave.current_radius
		wave_inner_radius = test_wave.inner_radius
		mask = test_wave.mask

	screen_mat.set_shader_parameter("wave_origin", wave_origin)
	screen_mat.set_shader_parameter("wave_radius", wave_radius)
	screen_mat.set_shader_parameter("wave_current_radius", wave_current_radius)
	screen_mat.set_shader_parameter("wave_inner_radius", wave_inner_radius)
	screen_mat.set_shader_parameter("mask", mask)


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
	collision_occluder_shape.shape.radius = wave_length
	var tex : ViewportTexture = await s_v_mask.get_mask(global_position, wave_length, occluders_inside.get_overlapping_bodies())
	wave_mask_debug.texture = tex

	var image: Image = tex.get_image()
	var new_tex := ImageTexture.create_from_image(image)
	image_debug.texture = new_tex
	return new_tex

