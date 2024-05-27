class_name SVMask
extends SubViewport

@onready var point_light: PointLight2D = %PointLight
@onready var bg: ColorRect = %BG
#@onready var camera: Camera2D = %Camera

var local_occluders : Array[LightOccluder2D] = []




# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_mask(_origin_pos : Vector2, _screen_size: float, _occluders: Array[Node2D]) -> ViewportTexture:
	size = Vector2.ONE * _screen_size
	#camera.position = Vector2.ONE * _screen_size * 0.5
	#camera.zoom.y = 1080/1920.0
	bg.size = Vector2.ONE * _screen_size

	var _size : float = point_light.texture.get_size().x
	point_light.texture_scale = _screen_size / _size
	point_light.position = Vector2.ONE * _screen_size * 0.5


	for occl: LightOccluder2D in local_occluders:
		occl.queue_free()
	local_occluders.clear()

	for i: int in range(_occluders.size()):
		var occl := LightOccluder2D.new()
		var to_copy: LightOccluder2D = _occluders[i].light_occluder_2d
		local_occluders.push_back(occl)
		add_child(occl)
		occl.position = Vector2.ONE * _screen_size *0.5 + to_copy.global_position - _origin_pos
		occl.occluder_light_mask = to_copy.occluder_light_mask
		occl.occluder = to_copy.occluder

		occl.visible = true

	await RenderingServer.frame_post_draw

	return get_texture()
