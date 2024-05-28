extends Control 
onready var pickables = $pickables
onready var plr = $pickables/player
onready var magnifier = $pickables/magnifier
onready var vp = $mainVPC/mainVP
onready var bg = $mainVPC/mainVP/bg
onready var selObj = plr
var dragObj : Object
var startPos : Vector2
var offset : Vector2
enum {KEEP, STRETCH}
func _ready():
	setMainArea()
	setMagnifier(Vector2(.6,.3))
	setPlr(Vector2(.3,.3))
	remove_child(pickables)
	vp.add_child(pickables)
	$bPanel/minimap/mapSize.value = 200
	# warning-ignore:return_value_discarded
	get_tree().connect("files_dropped", self, "_files_dropped")
func _physics_process(_delta):
	var mPos = $mainVPC.get_global_mouse_position()
	if Input.is_action_just_released("mouse_left"):
		dragObj = null
	if dragObj != null: 
		if dragObj != bg: 
			dragObj.position = Vector2(clamp(mPos.x + offset.x,0,vp.size.x),clamp(mPos.y + offset.y,0,vp.size.y))
			if dragObj != magnifier:
				$rPanel/plrView/plrVP/plrCam.position = dragObj.position
	else:
		if Input.is_action_just_pressed("mouse_left"):
			dragObj = getObjectFromMouse()
			if dragObj != null and dragObj != bg:
				startPos = mPos
				offset = dragObj.position - startPos
		if Input.is_action_just_pressed("mouse_right"):
			var o = getObjectFromMouse()
			if o!= null and o != bg and o != magnifier:
				var newObj : Sprite = o.duplicate()
				newObj.position = o.position + Vector2(10,10)
				pickables.add_child(newObj)
	if dragObj == magnifier: 
		magnifier.get_node("magVPC/magVP/magCam").position = dragObj.position
func setMainArea():
	vp.size = $mainVPC.rect_size
	setSpriteSize(bg, vp.size, KEEP)
	setSpriteSize($mainVPC/defBg, vp.size, STRETCH)
	bg.position = vp.size/2
func setMiniMap(mapSizeX):
	setSpriteSize($bPanel/minimap/miniview, Vector2(mapSizeX, mapSizeX * vp.size.y/vp.size.x), KEEP)
	setSpriteSize($bPanel/minimap/defBg,Vector2(mapSizeX, mapSizeX * vp.size.y/vp.size.x), STRETCH)
func setPlr(iniPos):
	plr.position = vp.size * iniPos
	$rPanel/plrView/plrVP.world_2d = vp.world_2d
	$rPanel/plrView/plrVP/plrCam.position = plr.position
func setMagnifier(initPos):
	magnifier.position = vp.size * initPos
	magnifier.get_node("magVPC/magVP").size = magnifier.get_node("magVPC").rect_size
	magnifier.get_node("magVPC/magVP").world_2d = vp.world_2d
	magnifier.get_node("projector").texture = magnifier.get_node("magVPC/magVP")
	magnifier.get_node("magVPC/magVP/magCam").position = magnifier.position
	magnifier.get_node("magnifierZoom").value = .8
func getObjectFromMouse():
	var obj = bg if mouseOnObject(bg) else null
	for o in pickables.get_children(): 
		if mouseOnObject(o) and o.get_class() == "Sprite": obj = o
	return obj
func _files_dropped(files, _screen):
	var img = Image.new()
	if img.load(files[0]) == OK:
		var dropObj = getObjectFromMouse()
		if dropObj != null and dropObj != magnifier:
			var tex = ImageTexture.new()
			tex.create_from_image(img,0)
			dropObj.texture = tex
			setSpriteSize(dropObj,vp.size if dropObj == bg else Vector2(80,80), KEEP)
func setSpriteSize(o : Sprite, sz : Vector2, mode : int):
	if mode == KEEP: 
		o.scale.x = min( sz.x / o.get_rect().size.x, sz.y / o.get_rect().size.y)
		o.scale.y = min( sz.x / o.get_rect().size.x, sz.y / o.get_rect().size.y)
	if mode == STRETCH:
		o.scale = sz / o.get_rect().size
func mouseOnObject(o): 
	return Rect2(o.get_rect().position * o.scale, o.get_rect().size * o.scale).has_point($mainVPC.get_global_mouse_position() - $mainVPC.rect_position - o.position)
func _on_magnifierZoom_value_changed(value):
	magnifier.get_node("magVPC/magVP/magCam").zoom = Vector2(value, value)
func _on_plrCamZoom_value_changed(value):
	$rPanel/plrView/plrVP/plrCam.zoom = Vector2($rPanel/plrView/plrCamZoom.max_value - value + .5,$rPanel/plrView/plrCamZoom.max_value - value +.5)
func _on_mapSize_value_changed(value):
	setMiniMap($bPanel/minimap/mapSize.max_value-value + 50)
