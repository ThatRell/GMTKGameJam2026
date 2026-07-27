class_name TimedSwitch
extends Interactable

var audio_switch: AudioStream = preload("res://assets/sounds/278205__ianstargem__switch-flip-1.wav")
var interactable: bool = true
var is_active: bool = false
var timer_wait_time: float = 4.0

@onready var timer: Timer = $Timer
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	timer.wait_time = timer_wait_time
	timer.timeout.connect(on_timeout)


func interact() -> void:
	if interactable:
		is_active = true
		animation_player.play("flip_switch")
		AudioManager.play_sfx(audio_switch)
		timer.start()


func on_timeout() -> void:
	print("INCORRECT BUZZER")
	AudioManager.play_sfx(audio_switch)
	is_active = false
	animation_player.play_backwards("flip_switch")


func on_puzzle_completed() -> void:
	interactable = false
	if not timer.is_stopped():
		timer.stop()
