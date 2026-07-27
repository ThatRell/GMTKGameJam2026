class_name EnemyAttackHandler
extends Node2D

const enemy_firing_audio: AudioStream = preload("res://assets/sounds/enemy_firing.wav")
const ENEMY_BULLET_SCENE: PackedScene = preload("uid://bwmyth58pm7h0")
const RANDOM_DELAY_MIN: float = 0.0
const RANDOM_DELAY_MAX: float = 0.2

var enemy_stats: EnemyStats

var can_attack: bool = true

var attack_on_cd: bool = true
var elapsed_time: float = 0.0
var random_delay_time: float = 0.0


func _process(delta: float) -> void:
	if not enemy_stats:
		return
	
	if attack_on_cd:
		elapsed_time += delta
		if elapsed_time >= enemy_stats.attack_cooldown + random_delay_time:
			attack_on_cd = false
		


func try_attack(attack_spawn_pos: Vector2, angle: float) -> void:
	if not can_attack or attack_on_cd or not enemy_stats:
		return
	attack(attack_spawn_pos, angle)


func attack(attack_spawn_pos: Vector2, angle: float) -> void:
	attack_on_cd = true
	random_delay_time = randf_range(RANDOM_DELAY_MIN, RANDOM_DELAY_MAX)
	elapsed_time = 0.0
	
	var new_bullet: BasicEnemyBullet = ENEMY_BULLET_SCENE.instantiate()
	new_bullet.bullet_stats = enemy_stats.bullet_stats
	new_bullet.global_position = attack_spawn_pos
	new_bullet.global_rotation = angle
	global_position += Vector2.RIGHT.rotated(global_rotation) * 7 # slime fix?
	SignalBus.on_enemy_bullet_shot.emit(new_bullet)
	AudioManager.play_sfx_2d(enemy_firing_audio, attack_spawn_pos)
