class_name Player
extends CharacterBody2D


const SPEED : float = 300.0

@export var wave_interval_time : float = 0.5
var wave_interval_timer : float= 0.0

@onready var sw_manager: SWManager = %SWManager


func _ready() -> void:
	SWSignal.sw_screen_ready.connect(_on_sw_screen_ready)

func _on_sw_screen_ready(_sw_screen: SWScreen) -> void:
	_sw_screen.node_to_follow = self

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
		var wave_launched := await sw_manager.ask_for_next_wave()
		print( "is wave launched : ", wave_launched)



