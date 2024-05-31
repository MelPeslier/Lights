@tool
extends EditorPlugin


const SW_SIGNAL_NAME : String = "SWSignal"
const SW_SIGNAL_PATH : String = "res://addons/soundwave/sw_signals.gd"


func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_autoload_singleton(SW_SIGNAL_NAME, SW_SIGNAL_PATH)


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_autoload_singleton(SW_SIGNAL_NAME)
