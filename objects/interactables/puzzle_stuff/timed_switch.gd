class_name TimedSwitch
extends Interactable

var interactable: bool = true
var is_active: bool = false
var timer_wait_time: float = 5.0

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.wait_time = timer_wait_time
	timer.timeout.connect(on_timeout)


func interact() -> void:
	if interactable:
		is_active = true
		timer.start()


func on_timeout() -> void:
	print("INCORRECT BUZZER")
	is_active = false


func on_puzzle_completed() -> void:
	interactable = false
	if not timer.is_stopped():
		timer.stop()
