class_name AttackManager
extends Node2D

# in the near future, create a spell to bullet mapping
# so that ur bullet scene changes based on what spell u have
const BASIC_BULLET_SCENE: PackedScene = preload("uid://j73g7i2mwhrn")

var shot_cooldown: float = 1 # depends on age + spell type
var shoot_windup: float = 0.0 # depends on age + spell type
var can_shoot: bool = true

@onready var rotation_offset: Node2D = %RotationOffset
@onready var shoot_position: Marker2D = %ShootPosition
@onready var shot_timer: Timer = %ShotTimer


func _ready() -> void:
	shot_timer.wait_time = shot_cooldown


func _physics_process(delta: float) -> void:
	rotation_offset.global_rotation = lerp_angle(rotation_offset.global_rotation, (get_global_mouse_position() - global_position).angle(), 6.5 * delta)
	
	if (Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot")) and can_shoot:
		can_shoot = false
		# add windup here
		shoot()
		shot_timer.start()


func shoot():
	var new_bullet: BasicBullet = BASIC_BULLET_SCENE.instantiate()
	new_bullet.global_position = shoot_position.global_position
	new_bullet.global_rotation = shoot_position.global_rotation
	SignalBus.on_player_bullet_shot.emit(new_bullet)


func _on_shot_timer_timeout() -> void:
	can_shoot = true
