class_name Player
extends CharacterBody2D

const MOVEMENT_ACCELERATION = 22.0

@export var movement_speed: float = 400.0
@export var dash_distance: float = 150.0
@export var dash_duration: float = 0.1
@export var dash_time_cost: int = 3
@export var health_component: HealthComponent

var can_move: bool = true
var can_take_damage: bool = true

var dash_direction: Vector2 = Vector2.ZERO
var starting_dash_pos: Vector2 = Vector2.ZERO
var final_dash_pos: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
#var can_dash: bool = true

var position_hp_queue: Array[PositionHPInfo] = []
#var recall_cooldown: float
#var can_recall: bool = true

# for the dash process and the recall
# make sure player has abilities in data before checking any of that related stuff
# scratch that, start doing the position_hp_queue early
# it's like how ekko players hold onto their ult upgrade because its alr calculated before even unlocking


func _ready() -> void:
	SignalBus.on_trigger_player_spawn.connect(_on_spawn)
	add_to_group("player")
	
	GameUi.visible = true


func _physics_process(delta: float) -> void:
	if dash_timer > 0.0:
		dash_logic(delta)
	else:
		movement_input(delta)
	
	
	non_movement_input(delta)
	move_and_slide()


func movement_input(delta: float) -> void:
	if not can_move:
		velocity = Vector2.ZERO
		return
	
	var input_vector = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()
	
	velocity = lerp(velocity, input_vector * movement_speed, MOVEMENT_ACCELERATION * delta)
	
	if Input.is_action_just_pressed("dash"):
		if input_vector != Vector2.ZERO:
			dash(input_vector) # based on player input
		elif velocity.length() > 0.1:
			dash(velocity.normalized()) # else default on if there's velocity in a direction


func non_movement_input(delta: float) -> void:
	if Input.is_action_just_pressed("test"):
		TimeManager.toggle_clock_mode()
	
	if Input.is_action_just_pressed("test2"):
		TimeManager.is_paused = false


func dash(direction: Vector2) -> void:
	dash_direction = direction
	dash_timer = dash_duration
	starting_dash_pos = global_position
	final_dash_pos = global_position + (dash_direction * dash_distance)
	can_take_damage = false
	TimeManager.subtract_from_slot(Utility.TimeSlot.B, dash_time_cost)


func dash_logic(delta: float) -> void:
	var dash_progress = 1.0 - (dash_timer / dash_duration)
	dash_progress = clamp(dash_progress, 0.0, 1.0)
	global_position = lerp(starting_dash_pos, final_dash_pos, dash_progress)
	
	# velocity should be max during and after the dash
	velocity = dash_direction * movement_speed
	
	dash_timer -= delta
	if dash_timer <= 0.0:
		dash_direction = Vector2.ZERO
		can_take_damage = true # probably want to add some frames after the dash where u cant take damage


func _on_spawn(spawn_position: Vector2, spawn_direction: String) -> void:
	global_position = spawn_position
	# do some stuff with spawn direction here
