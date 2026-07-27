extends Node2D

const menu_click_audio: AudioStream = preload("res://assets/sounds/733769__slv443__click-menu.wav")

@export var initial_scene: StringName = &""

@onready var play_button: Button = %PlayButton
@onready var quit_button: Button = %QuitButton


func _ready() -> void:
	GameUi.visible = false
	play_button.pressed.connect(_on_button_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	

func _on_button_pressed() -> void:
	AudioManager.play_sfx(menu_click_audio)
	SceneLoader.entry_point = "Spawn"
	SceneLoader.load_scene(initial_scene)


func _on_quit_pressed() -> void:
	AudioManager.play_sfx(menu_click_audio)
	get_tree().quit()
