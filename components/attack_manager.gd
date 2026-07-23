class_name AttackManager
extends Node2D

# in the near future, create a spell to bullet mapping
# so that ur bullet scene changes based on what spell u have
const BASIC_BULLET_SCENE: PackedScene = preload("uid://j73g7i2mwhrn")

var can_shoot: bool = true # as in if ur able to shoot
var is_dashing: bool = false
var freeze_cds: bool = false

var shot_cooldown: float = 1.0 # depends on age + spell type
var shot_on_cd: bool = false # if u were able to shoot and u shot
var shot_elapsed_time: float = 0.0

var shot_windup: float = 1.0 # depends on age + spell type
var winding_up: bool = false
var windup_elapsed_time: float = 0.0

@onready var rotation_offset: Node2D = %RotationOffset
@onready var shoot_position: Marker2D = %ShootPosition


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if freeze_cds:
		return
	
	rotation_offset.global_rotation = lerp_angle(rotation_offset.global_rotation, (get_global_mouse_position() - global_position).angle(), 6.5 * delta)
	
	if winding_up:
		windup_elapsed_time += delta
		if windup_elapsed_time >= shot_windup:
			#print("windup done")
			winding_up = false
			shoot()
			shot_elapsed_time += windup_elapsed_time - shot_windup
	elif shot_on_cd:
		shot_elapsed_time += delta
		if shot_elapsed_time >= shot_cooldown:
			#print("shot cd done")
			shot_on_cd = false
	elif not shot_on_cd and shot_elapsed_time > 0.0 and not is_dashing:
		shot_elapsed_time -= delta
	
	if (
			(Input.is_action_just_pressed("shoot") or Input.is_action_pressed("shoot")) and can_shoot
			and not shot_on_cd and not winding_up and not is_dashing
	):
		shot_on_cd = true
		start_windup()


func start_windup() -> void:
	var diff: float = shot_elapsed_time - shot_cooldown
	shot_elapsed_time = 0.0
	
	# skip wind up
	if shot_windup <= 0.0 or diff >= shot_windup:
		shoot()
		return
	
	winding_up = true
	windup_elapsed_time = 0.0


func shoot():
	var new_bullet: BasicBullet = BASIC_BULLET_SCENE.instantiate()
	new_bullet.global_position = shoot_position.global_position
	new_bullet.global_rotation = shoot_position.global_rotation
	SignalBus.on_player_bullet_shot.emit(new_bullet)
