class_name Dungeon
extends Node2D


func _ready() -> void:
	if TimeManager.clock_mode != Utility.ClockMode.MSM:
		TimeManager.toggle_clock_mode()
