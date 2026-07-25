@tool
extends Area2D

const MAX_SPAWN_DISTANCE: float = 90.0
const MIN_SPAWN_DISTANCE: float = 50.0
const FAIL_SAFE_DISTANCE: float = 250.0
const FAIL_SAFE_DISTANCE_SQUARED: float = FAIL_SAFE_DISTANCE * FAIL_SAFE_DISTANCE
const PUSH_MULTIPLIER: float = 7.0

@export var spawner_id: String
@export var enemy_container: Node2D
@export var enemy_scenes: Array[PackedScene]
@export var tilemap: TileMapLayer
@export var cells: Array[Vector2i]
@export var source: int
@export var atlas_coords: Vector2i

@export_group("Editor Setup")
@export var marker_layer_path: NodePath
@export var grab_cells: bool = false:
	set(value):
		if value:
			call_deferred("_grab_cells_from_marker")
		grab_cells = false

var is_cleared: bool = false
var is_active: bool = false
var enemy_dict: Dictionary[Enemy, bool] = {}
var player: Player

@onready var spawn_origin: Marker2D = %SpawnOrigin


func _ready() -> void:
	if not Engine.is_editor_hint():
		if Global.game_data and Global.game_data.cleared_areas.get(spawner_id, false):
			is_cleared = true


func _process(delta: float) -> void:
	if is_cleared or not is_active:
		return
	
	if is_active and enemy_dict.is_empty():
		Global.game_data.cleared_areas[spawner_id] = true
		is_cleared = true
		open_arena()
		
		set_process(false)
		set_deferred("monitoring", false)
	
	if player:
		var distance_squared: float = player.global_position.distance_squared_to(spawn_origin.global_position)
		if distance_squared >= FAIL_SAFE_DISTANCE_SQUARED:
			fail_safe()


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player) or is_active  or is_cleared:
		return
	
	close_arena()
	
	player = body as Player
	
	# this could work
	player.global_position += player.velocity.normalized() * PUSH_MULTIPLIER
	
	player.can_recall = false
	get_tree().create_timer(player.SECONDS_TO_GO_BACK).timeout.connect(
		func() -> void:
			player.can_recall = true
	)
	player.can_dash = false
	get_tree().create_timer(player.dash_cooldown).timeout.connect(
		func() -> void:
			player.can_dash = true
	)
	
	if not is_active:
		call_deferred("spawn_enemies")
		is_active = true


func spawn_enemies() -> void:
	if not spawn_origin:
		return
	
	for scene: PackedScene in enemy_scenes:
		var node: Node = scene.instantiate()
		if not (node is Enemy):
			continue
		
		var enemy: Enemy = node as Enemy
		
		enemy_dict[enemy] = true
		enemy.health_component.died.connect(clear_invalid_enemies.bind(enemy))
		
		enemy.global_position = random_spawn_position()
		enemy_container.add_child(enemy)


func random_spawn_position() -> Vector2:
	var direction: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var magnitude: = randf_range(MIN_SPAWN_DISTANCE, MAX_SPAWN_DISTANCE)
	return spawn_origin.global_position + (direction * magnitude)


func fail_safe() -> void:
	print("fail safe activated")
	is_active = false
	is_cleared = false
	
	for enemy: Enemy in enemy_dict:
		enemy.queue_free()
	
	enemy_dict.clear()
	
	open_arena()


func clear_invalid_enemies(enemy: Enemy):
	enemy_dict.erase(enemy)


func close_arena() -> void:
	if not tilemap:
		return
	
	for cell: Vector2i in cells:
		tilemap.set_cell(cell, source, atlas_coords)


func open_arena() -> void:
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
