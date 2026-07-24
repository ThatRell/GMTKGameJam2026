class_name EnemyIdle
extends State

@export var enemy: Enemy
var player: Player

var move_direction: Vector2
var wander_time: float


func randomize_wander() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)


func enter() -> void:
	player = get_tree().get_first_node_in_group("player")
	randomize_wander()


func update(delta: float) -> void:
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()


func physics_update(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direction * enemy.stats.move_speed
	
	var distance: Vector2 = player.global_position - enemy.global_position
	if distance.length() < enemy.stats.detection_radius:
		transitioned.emit(self, "EnemyFollow")
