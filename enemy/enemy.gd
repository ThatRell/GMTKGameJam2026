class_name Enemy
extends CharacterBody2D

const explosion_audio: AudioStream = preload("res://assets/sounds/01_Explosion_v1.wav")
const punch_audio: AudioStream = preload("res://assets/sounds/01_Punch_v3.wav")

@export var stats: EnemyStats
@export var health_component: HealthComponent
@export var attack_handler: EnemyAttackHandler

var frozen: int = 0

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_spawn_pos: Marker2D = %AttackSpawnPos
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	health_component.set_max_health(stats.max_health)
	health_component.died.connect(on_enemy_died)
	health_component.took_damage.connect(on_hit)
	attack_handler.enemy_stats = stats


func _process(delta: float) -> void:
	if frozen < 0:
		frozen = 0
	
	if frozen == 0:
		attack_handler.can_attack = true
	else:
		attack_handler.can_attack = false
		
	if velocity.x > 0:
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true


func _physics_process(delta: float) -> void:
	if frozen > 0:
		return
	move_and_slide()


func on_enemy_died() -> void:
	AudioManager.play_sfx_2d(explosion_audio, global_position)
	queue_free()


func on_hit() -> void:
	AudioManager.play_sfx_2d(punch_audio, global_position)
