extends Node2D

@export var initial_scene: StringName = &""

@onready var play_button: Button = %PlayButton


func _ready() -> void:
	play_button.pressed.connect(_on_button_pressed)
	

func _on_button_pressed() -> void:
	SceneLoader.load_scene(initial_scene)
