class_name BaseBullet
extends Area2D

signal destroyed
const bullet_destroy_audio: AudioStream = preload("res://assets/sounds/bullet_destroy.wav")

@export var bullet_stats: BulletStats
var life_time: float = 20.0
var frozen: int = 0

@onready var timer: SceneTreeTimer = get_tree().create_timer(life_time)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_bullet_timeout)


func _process(delta: float) -> void:
	if frozen < 0:
		frozen = 0


func _physics_process(delta: float) -> void:
	if frozen > 0:
		return
	
	global_position += Vector2.RIGHT.rotated(global_rotation) * bullet_stats.speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		#print("damaged")
		var hitbox: HitboxComponent = area
		if not hitbox.can_get_hit:
			return
		
		hitbox.damage(bullet_stats.damage)
		
		var parent = hitbox.get_parent()
		if parent is Player:
			parent = parent as Player
			hitbox.player_dodge_result.connect(on_player_result, CONNECT_ONE_SHOT)
			return
		
		if not bullet_stats.can_pierce:
			destroyed.emit()
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	#print("hit a wall")
	destroy()


func _on_bullet_timeout() -> void:
	#print("bullet memory freed")
	destroy()


func on_player_result(successful: bool) -> void:
	if not successful and not bullet_stats.can_pierce:
		destroy()


func destroy() -> void:
	AudioManager.play_sfx_2d(bullet_destroy_audio, global_position)
	destroyed.emit()
	queue_free()
