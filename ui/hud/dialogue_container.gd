extends Control

var hide_wait_time: float = 20.0
var delay_wait_time: float = 0.2

@onready var explanation_label = %Explanations
@onready var hide_timer: Timer = $HideTimer
@onready var delay: Timer = $Delay


func _ready() -> void:
	hide_timer.wait_time = hide_wait_time
	hide_timer.timeout.connect(on_hide_timer_timeout)
	delay.wait_time = delay_wait_time
	SignalBus.on_text_trigger.connect(update)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed('interact') and delay.is_stopped() and visible:
		if not hide_timer.is_stopped():
			hide_timer.stop()
		visible = false


func update(text: String) -> void:
	explanation_label.text = text
	visible = true
	hide_timer.start()
	delay.start()


func on_hide_timer_timeout() -> void:
	visible = false
