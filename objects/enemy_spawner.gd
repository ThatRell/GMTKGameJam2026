extends Area2D

const MAX_SPAWN_DISTANCE: float = 90.0

@export var spawner_id: String
@export var spawn_origin: Marker2D
@export var enemy_container: Node2D
@export var enemy_scenes: Array[PackedScene]

var is_cleared: bool = false
var is_active: bool = false
var enemy_dict: Dictionary[Enemy, bool] = {}


func _ready() -> void:
	if Global.game_data.cleared_areas.get(spawner_id, false):
		is_cleared = true


func _process(delta: float) -> void:
	if is_cleared or not is_active:
		return
	
	if is_active and enemy_dict.is_empty():
		print("cleared!")
		Global.game_data.cleared_areas[spawner_id] = true
		is_cleared = true
		set_process(false)
		set_deferred("monitoring", false)


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player) or is_cleared:
		return
	
	if not is_active:
		spawn_enemies()
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
		enemy.health_component.died.connect(
			func() -> void:
				enemy_dict.erase(enemy)
				enemy.queue_free()
		)
		
		enemy.global_position = random_spawn_position()
		enemy_container.add_child(enemy)


func random_spawn_position() -> Vector2:
	var direction: Vector2 = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	var magnitude: = randf_range(1, MAX_SPAWN_DISTANCE)
	return spawn_origin.global_position + (direction * magnitude)
