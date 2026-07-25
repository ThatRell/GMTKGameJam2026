class_name Dungeon
extends Node2D

const BACKGROUND_COLOR_CODE: String = "#0D0020"


func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.html(BACKGROUND_COLOR_CODE))
	if TimeManager.clock_mode != Utility.ClockMode.MSM:
		TimeManager.toggle_clock_mode()
