class_name SWMaskBaker
extends SubViewport

@onready var point_light: PointLight2D = %PointLight
@onready var bg: Sprite2D = %BG
@onready var camera: Camera2D = %Camera

var local_occluders : Array[LightOccluder2D] = []
var local_tile_maps : Array[TileMap] = []

# TODO : Duplicating may cost  performances ? so how can we do it differently ? (#Not makng a mask in a subviewport ?)
# TODO : Reduce the time of the process by not awaiting, but just calling the function, then let it call an other funciton once it has finished

func _ready() -> void:
	SWSignal.sw_mask_baker_ready.emit(self)
	await RenderingServer.frame_post_draw
	get_mask(Vector2.ZERO, 512.0, [])



# Called every frame. 'delta' is the elapsed time since the previous frame.
func get_mask(_origin_pos : Vector2, _wave_radius: float, _occluders: Array[Node2D]) -> ImageTexture:
	# Updating positions 'center on the wave emission point'
	camera.position = _origin_pos
	point_light.position = _origin_pos
	bg.position = _origin_pos

	# Resizing the textures size to fit the radius of the wave (scalable for any size of lights)
	# 256.0 is the texture size of light and background
	var scale_coef : float = _wave_radius / 256.0
	point_light.texture_scale = scale_coef * 2.0
	bg.scale = scale_coef * Vector2.ONE * 2.0

	# Most important part, so we actually see the whole thing !
	camera.zoom = Vector2.ONE / scale_coef

	# Remove local light occluders before re adding new ones
	for occl: LightOccluder2D in local_occluders:
		occl.queue_free()
	local_occluders.clear()
	for map : TileMap in local_tile_maps:
		map.queue_free()
	local_tile_maps.clear()

	for i: int in range(_occluders.size()):
		var _actual = _occluders[i]

		# Add each 'ground' class to the subviewport owrld then delete them on next update
		if _actual is Ground:
			var occl := LightOccluder2D.new()
			var to_copy: LightOccluder2D = _occluders[i].light_occluder_2d
			local_occluders.push_back(occl)
			add_child(occl)
			occl.position = to_copy.global_position
			occl.occluder_light_mask = to_copy.occluder_light_mask
			occl.occluder = to_copy.occluder
			occl.visible = true
		elif _actual is TileMap: # TODO find a way to not suplicatethe tile map ? Is it costly ?
			var new : TileMap = _actual.duplicate()
			local_tile_maps.push_back(new)
			add_child(new)
		
		# TODO Add you  own ligic for other types that are in the light layer 2 to add the maked part that we need:)
		
	await RenderingServer.frame_post_draw
	var viewport_texture : ViewportTexture = get_texture()
	var image: Image = viewport_texture.get_image()
	var image_texture := ImageTexture.create_from_image(image)
	return image_texture
