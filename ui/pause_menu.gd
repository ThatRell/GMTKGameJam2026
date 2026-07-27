extends Control

@onready var reset_button: Button = %ResetButton
@onready var menu_button: Button = %MenuButton

func _ready() -> void:
	visible = false
	reset_button.pressed.connect(on_reset_pressed)
	menu_button.pressed.connect(on_menu_pressed)


func _process(delta: float) -> void:
	if not SceneLoader.current_scene == "Dungeon":
		return
	
	if Input.is_action_just_pressed("pause"):
		if visible:
			visible = false
			Engine.time_scale = 1.0
		else:
			visible = true
			Engine.time_scale = 0.0


func on_menu_pressed() -> void:
	visible = false
	Engine.time_scale = 1.0
	SceneLoader.load_scene("MainMenu")


func on_reset_pressed() -> void:
	visible = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
