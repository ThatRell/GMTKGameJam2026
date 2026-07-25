class_name EnemyAttacking
extends State

@export var enemy: Enemy
var player: Player

var move_direction: Vector2
var strafe_time: float


func randomize_strafe() -> void:
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	strafe_time = randf_range(1, 2)


func enter() -> void:
	player = get_tree().get_first_node_in_group("player")


func update(delta: float) -> void:
	if strafe_time > 0.0:
		strafe_time -= delta
	else:
		randomize_strafe()


func physics_update(delta: float) -> void:
	if enemy:
		enemy.velocity = move_direction * enemy.stats.move_speed
	
	var distance: Vector2 = player.global_position - enemy.global_position
	if distance.length() > enemy.stats.attack_radius:
		await get_tree().create_timer(strafe_time).timeout
		transitioned.emit(self, "EnemyFollow")
	else:
		enemy.attack_handler.try_attack(enemy.attack_spawn_pos.global_position, distance.angle())
