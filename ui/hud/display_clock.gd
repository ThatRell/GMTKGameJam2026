extends Control

@onready var label: Label = %Label


func _ready() -> void:
	TimeManager.updated.connect(update_display)
	update_display()


func update_display() -> void:
	label.text = TimeManager.get_display_string()
