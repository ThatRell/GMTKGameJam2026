class_name Player
extends CharacterBody2D

@export var speed: float = 400.0

var can_move: bool = true


func _ready() -> void:
	SignalBus.on_trigger_player_spawn.connect(_on_spawn)
	add_to_group("player")
	
	GameUi.visible = true


func _physics_process(delta: float) -> void:
	get_input(delta)
	move_and_slide()


func get_input(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	if Input.is_action_just_pressed("test"):
		TimeManager.toggle_clock_mode()
	
	if Input.is_action_just_pressed("test2"):
		TimeManager.is_paused = false
	
	var input_direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed


func _on_spawn(spawn_position: Vector2, spawn_direction: String) -> void:
	global_position = spawn_position
	# do some stuff with spawn direction here
