class_name Exit
extends Area2D

@export var target_room: String
@export var entry_point: String
@export var is_active: bool = true


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player) or not is_active:
		return
	
	# save room data and everything in it
	
	# entry point can be any node identified by its name
	# typical names are "Left", "Right", "Top", "Bottom"
	# and these can be like a 2D node, marker2d, etc.
	# that has a script to edit player spawn direction or something idk
	
	SceneLoader.entry_point = entry_point
	SceneLoader.load_scene(target_room)
