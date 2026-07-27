class_name EnemyFollow
extends State

@export var enemy: Enemy
var player: Player


func enter() -> void:
	player = get_tree().get_first_node_in_group("player")


func physics_update(delta: float) -> void:
	var distance: Vector2 = player.global_position - enemy.global_position
	
	if distance.length() > enemy.stats.detection_radius:
		transitioned.emit(self, "EnemyIdle")
	elif distance.length() > enemy.stats.attack_radius: #(i think i can make this negative for the boss)
		enemy.velocity = distance.normalized() * enemy.stats.move_speed
	else:
		transitioned.emit(self, "EnemyAttacking")
