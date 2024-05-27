class_name SVMask
extends SubViewport

@onready var point_light: PointLight2D = %PointLight
@onready var bg: ColorRect = %BG
@onready var camera: Camera2D = %Camera

var local_occluders : Array[LightOccluder2D] = []




# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_mask(_origin_pos : Vector2, _wave_length, _occluders: Array[Node2D]) -> ViewportTexture:
	print("oui")
	size = Vector2(_wave_length, _wave_length)
	camera.position = Vector2.ONE * _wave_length / 2.0
	bg.size = Vector2.ONE * _wave_length

	var _size : float = point_light.texture.get_size().x
	point_light.texture_scale = _wave_length / _size
	point_light.position = Vector2.ONE * _wave_length / 2.0


	for occl: LightOccluder2D in local_occluders:
		occl.queue_free()
	local_occluders.clear()

	for i: int in range(_occluders.size()):
		var occl := LightOccluder2D.new()
		var to_copy: LightOccluder2D = _occluders[i].light_occluder_2d
		local_occluders.push_back(occl)
		add_child(occl)
		occl.position = Vector2.ONE * _wave_length / 2.0 + to_copy.global_position - _origin_pos
		occl.occluder_light_mask = to_copy.occluder_light_mask
		occl.occluder = to_copy.occluder

		occl.visible = true

	await RenderingServer.frame_post_draw

	return get_texture()
