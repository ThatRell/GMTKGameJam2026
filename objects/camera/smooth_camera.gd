class_name SmoothCamera
extends Camera2D

const VIEWPORT_X_PERCENTAGE = 0.20
const VIEWPORT_Y_PERCENTAGE = 0.20

var desired_offset: Vector2
var player: Player


func _physics_process(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("player")
		return
	
	var world_view_size: Vector2 = get_viewport_rect().size / zoom
	var mouse_offset: Vector2 = get_global_mouse_position() - global_position
	var max_offset: Vector2 = world_view_size * Vector2(VIEWPORT_X_PERCENTAGE, VIEWPORT_Y_PERCENTAGE)
	
	desired_offset = mouse_offset * 0.5
	desired_offset.x = clamp(desired_offset.x, -max_offset.x, max_offset.x)
	desired_offset.y = clamp(desired_offset.y, -max_offset.y, max_offset.y)
	
	global_position = player.global_position + desired_offset
