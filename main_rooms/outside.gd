class_name Outside
extends Node2D

const BACKGROUND_COLOR_CODE: String = "#A799CC"


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html(BACKGROUND_COLOR_CODE))
	if TimeManager.clock_mode != Utility.ClockMode.HMS:
		TimeManager.toggle_clock_mode()
	
	if TimeManager.is_finished:
		TimeManager.reset_clock()
		TimeManager.is_finished = false
		TimeManager.is_paused = false
		Global.game_data.reset_on_death()
