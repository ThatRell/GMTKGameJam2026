@tool
class_name Campfire
extends Area2D

const go_out_audio: AudioStream = preload("res://assets/sounds/go_out.wav")
const flame_audio: AudioStream = preload("res://assets/sounds/flame.wav")

@export var cells: Array[Vector2i]
@export var tilemap: TileMapLayer

@export_group("Editor Setup")
@export var marker_layer_path: NodePath
@export var grab_cells: bool = false:
	set(value):
		if value:
			call_deferred("_grab_cells_from_marker")
		grab_cells = false


@onready var moving_sprite: Sprite2D = $MovingSprite
@onready var timer: Timer = $Timer

var wait_time: float = 1.7
var puzzle_completed: bool = false
var audio_complete: AudioStream = preload("res://assets/sounds/779817__kenneth_cooney__success2.wav")


func _ready() -> void:
	timer.wait_time = wait_time
	timer.timeout.connect(on_timeout)
	moving_sprite.visible = false
	if not Engine.is_editor_hint():
		if Global.game_data.time_stop_puzzle_solved:
			completed_puzzle()
			open_lock()


func _on_area_entered(area: Area2D) -> void:
	if puzzle_completed:
		return
	
	if area is BasicBullet:
		timer.start()
		moving_sprite.visible = true
		AudioManager.play_sfx_2d(flame_audio, global_position)
	elif area is BasicEnemyBullet:
		if not timer.is_stopped():
			AudioManager.play_sfx_2d(go_out_audio, global_position)
		timer.stop()
		moving_sprite.visible = false


func on_timeout() -> void:
	AudioManager.play_sfx(audio_complete)
	completed_puzzle()
	open_lock()


func completed_puzzle() -> void:
	print("puzzle solved")
	puzzle_completed = true
	Global.game_data.time_stop_puzzle_solved = true
	moving_sprite.visible = true


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
