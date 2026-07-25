class_name Outside
extends Node2D


func _ready() -> void:
	if TimeManager.clock_mode != Utility.ClockMode.HMS:
		TimeManager.toggle_clock_mode()
	
	if TimeManager.is_finished:
		TimeManager.reset_clock()
		TimeManager.is_finished = false
		Global.game_data.reset_on_death()
