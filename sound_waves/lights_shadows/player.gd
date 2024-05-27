class_name Player
extends CharacterBody2D


const SPEED = 300.0
@export var wave_length : float = 900 :
	set(_new):
		wave_length = _new
		if is_inside_tree():
			collision_occluder_shape.shape.size = Vector2.ONE * wave_length
@export var s_v_mask : SVMask

@onready var occluders_inside: Area2D = %OccludersInside
@onready var wave_mask_debug: TextureRect = %WaveMaskDebug
@onready var collision_occluder_shape: CollisionShape2D = $OccludersInside/CollisionOccluderShape
@onready var image_debug: TextureRect = %ImageDebug

func _ready() -> void:
	wave_length = wave_length
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
		update_tex()


func update_tex() -> void:
		if not s_v_mask :
			print("no sub viewport")
			return
		var tex : ViewportTexture = await s_v_mask.get_mask(global_position, wave_length, occluders_inside.get_overlapping_bodies())
		wave_mask_debug.texture = tex

		var image: Image = tex.get_image()
		var new_tex := ImageTexture.create_from_image(image)
		image_debug.texture = new_tex

