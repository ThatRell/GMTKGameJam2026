class_name EnemyAttackHandler
extends Node2D

const ENEMY_BULLET_SCENE: PackedScene = preload("uid://bwmyth58pm7h0")

var enemy_stats: EnemyStats

var can_attack: bool = true

var attack_on_cd: bool = false
var elapsed_time: float = 0.0


func _process(delta: float) -> void:
	if not enemy_stats:
		return
	
	if attack_on_cd:
		elapsed_time += delta
		if elapsed_time >= enemy_stats.attack_cooldown:
			attack_on_cd = false
		


func try_attack(attack_spawn_pos: Vector2, angle: float) -> void:
	if not can_attack or attack_on_cd or not enemy_stats:
		return
	attack(attack_spawn_pos, angle)


func attack(attack_spawn_pos: Vector2, angle: float) -> void:
	attack_on_cd = true
	elapsed_time = 0.0
	
	var new_bullet: BasicEnemyBullet = ENEMY_BULLET_SCENE.instantiate()
	new_bullet.global_position = attack_spawn_pos
	new_bullet.global_rotation = angle
	SignalBus.on_enemy_bullet_shot.emit(new_bullet)
