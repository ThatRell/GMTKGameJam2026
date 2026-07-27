class_name AttackManager
extends Node2D

const firing_sound: AudioStream = preload("res://assets/sounds/firing_sound_player.wav")
const BULLET_SCENES: Dictionary[String, PackedScene] = {
	"BasicSpell": preload("uid://j73g7i2mwhrn"),
	"PiercingBolt": preload("uid://mr8eg08htsm3"),
}
const BASIC_SPELL_STATS: SpellStats = preload("uid://702t2ryjn0fu")

var can_shoot: bool = true # as in if ur able to shoot
var is_dashing: bool = false
var freeze_cds: bool = false

var shot_cooldown: float
var current_cooldown: float = 0.0
var shot_on_cd: bool = false # if u were able to shoot and u shot
var shot_elapsed_time: float = 0.0

var shot_windup: float
var current_windup: float = 0.0
var winding_up: bool = false
var windup_elapsed_time: float = 0.0

var current_spell_index: int = 0

@onready var rotation_offset: Node2D = %RotationOffset
@onready var shoot_position: Marker2D = %ShootPosition


func _ready() -> void:
	set_cd_and_windup()


func _process(delta: float) -> void:
	if Input.is_action_just_released("mouse_wheel_up"):
		if winding_up:
			cancel_shoot()
		
		current_spell_index += 1
		if current_spell_index >= Global.game_data.spell_array.size():
			current_spell_index = 0
	
	if Input.is_action_just_pressed("mouse_wheel_down"):
		if winding_up:
			cancel_shoot()
		
		current_spell_index -= 1
		if current_spell_index < 0:
			current_spell_index = Global.game_data.spell_array.size() - 1
	
	set_cd_and_windup()
	
	if freeze_cds:
		return
	
	rotation_offset.global_rotation = lerp_angle(rotation_offset.global_rotation, (get_global_mouse_position() - global_position).angle(), 60 * delta)
	
	if winding_up:
		windup_elapsed_time += delta
		if windup_elapsed_time >= current_windup:
			#print("windup done")
			winding_up = false
			shoot()
			shot_elapsed_time += windup_elapsed_time - current_windup
	elif shot_on_cd:
		shot_elapsed_time += delta
		if shot_elapsed_time >= current_cooldown:
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
	current_cooldown = shot_cooldown
	current_windup = shot_windup
	var diff: float = shot_elapsed_time - current_cooldown
	shot_elapsed_time = 0.0
	
	# skip wind up
	if current_windup <= 0.0 or diff >= current_windup:
		shoot()
		return
	
	winding_up = true
	windup_elapsed_time = 0.0


func shoot():
	var current_spell: SpellStats = Global.game_data.spell_array[current_spell_index]
	var new_bullet: BasicBullet = BULLET_SCENES.get(current_spell.spell_name, "BasicSpell").instantiate()
	new_bullet.bullet_stats = current_spell.bullet_stats
	new_bullet.global_position = shoot_position.global_position
	new_bullet.global_rotation = shoot_position.global_rotation
	SignalBus.on_player_bullet_shot.emit(new_bullet)
	AudioManager.play_sfx(firing_sound)


func cancel_shoot() -> void:
	winding_up = false
	shot_on_cd = false
	shot_elapsed_time = 0.0


func set_cd_and_windup() -> void:
	if Global.game_data.spell_array.is_empty():
		Global.game_data.spell_array.append(BASIC_SPELL_STATS)
	var current_spell = Global.game_data.spell_array[current_spell_index]
	shot_cooldown = current_spell.shot_cooldown
	shot_windup = current_spell.shot_windup
	SignalBus.on_current_spell_updated.emit(current_spell.spell_name)
