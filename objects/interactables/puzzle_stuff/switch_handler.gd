@tool
extends Node2D

# lwk this node could just be the door and go into puzzle stuff
# like after both are active then it queue frees or something
@export var cells: Array[Vector2i]
@export var tilemap: TileMapLayer
@export var switch_one: TimedSwitch
@export var switch_two: TimedSwitch

@export_group("Editor Setup")
@export var marker_layer_path: NodePath
@export var grab_cells: bool = false:
	set(value):
		if value:
			call_deferred("_grab_cells_from_marker")
		grab_cells = false

var audio_complete: AudioStream = preload("res://assets/sounds/779817__kenneth_cooney__success2.wav")
var puzzle_completed: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		if Global.game_data.recall_puzzle_solved:
			on_puzzle_complete()


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if puzzle_completed:
		return
	
	if (
		(switch_one.interactable and switch_two.interactable) and (switch_one.is_active and switch_two.is_active)
	):
		AudioManager.play_sfx(audio_complete)
		on_puzzle_complete()


func on_puzzle_complete() -> void:
	Global.game_data.recall_puzzle_solved = true
	puzzle_completed = true
	switch_one.on_puzzle_completed()
	switch_two.on_puzzle_completed()
	open_lock()


func open_lock() -> void:
	if not tilemap:
		return
	
	for cell: Vector2i in cells:
		tilemap.set_cell(cell, -1)


func _grab_cells_from_marker() -> void:
	var marker_layer: TileMapLayer = get_node_or_null(marker_layer_path) as TileMapLayer
	
	if not marker_layer:
		print("returned")
		return
	
	cells.clear()
	
	for cell: Vector2i in marker_layer.get_used_cells():
		var atlas_coords: Vector2i = marker_layer.get_cell_atlas_coords(cell)
		
		if atlas_coords == Vector2i(0, 0):
			cells.append(cell)
		elif atlas_coords == Vector2i(1, 0):
			printerr("use red on entrances")
			break
	
	marker_layer.clear()
