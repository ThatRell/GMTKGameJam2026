extends Node2D

const ARROW_BULLET: PackedScene = preload("uid://daui6bnynbbvo")

var wait_time: float = 0.5
var is_active: bool = true

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var marker_2d: Marker2D = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = wait_time
	timer.timeout.connect(on_timeout)
	if Global.game_data.time_stop_puzzle_solved:
		on_puzzle_complete()
	else:
		timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_active:
		return
	
	if Global.game_data.time_stop_puzzle_solved:
		on_puzzle_complete()


func on_puzzle_complete() -> void:
	is_active = false
	timer.stop()
	set_process(false)


func on_timeout() -> void:
	animation_player.play("firing")
	var new_bullet: BasicEnemyBullet = ARROW_BULLET.instantiate()
	new_bullet.global_position = marker_2d.global_position
	SignalBus.on_enemy_bullet_shot.emit(new_bullet)
