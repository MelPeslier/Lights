extends PointLight2D

@export var vp : SubViewport

func _process(delta: float) -> void:
	if not vp : return
	await RenderingServer.frame_post_draw
	var viewport_texture : ViewportTexture = vp.get_texture()
	#var image: Image = viewport_texture.get_image()
	#var image_texture := ImageTexture.create_from_image(image)
	texture = viewport_texture
