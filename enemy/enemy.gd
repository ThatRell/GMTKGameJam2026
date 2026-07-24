class_name Enemy
extends CharacterBody2D

@export var stats: EnemyStats
@export var health_component: HealthComponent
@export var attack_handler: EnemyAttackHandler

var frozen: int = 0

@onready var attack_spawn_pos: Marker2D = %AttackSpawnPos


func _ready() -> void:
	health_component.max_health = stats.max_health
	health_component.died.connect(on_enemy_died)
	attack_handler.enemy_stats = stats


func _process(delta: float) -> void:
	if frozen < 0:
		frozen = 0
	
	if frozen == 0:
		attack_handler.can_attack = true
	else:
		attack_handler.can_attack = false
	#if velocity.length() > 0:
		#animation player.play("run")
	#if velocity.x > 0:
		#sprite.flip_h = false
	#else:
		#sprite.flip_h = true


func _physics_process(delta: float) -> void:
	if frozen > 0:
		return
	move_and_slide()


func on_enemy_died() -> void:
	queue_free()
