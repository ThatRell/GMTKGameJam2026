class_name Outside
extends Node2D


func _ready() -> void:
	if TimeManager.clock_mode != Utility.ClockMode.HMS:
		TimeManager.toggle_clock_mode()
	
	if TimeManager.is_finished:
		TimeManager.set_clock(6, 0, 0) # reset clock
		TimeManager.is_finished = false
