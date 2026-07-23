class_name Player
extends CharacterBody2D

const MOVEMENT_ACCELERATION: float = 22.0
const MAX_QUEUE_SIZE: int = 15
const SECONDS_TO_GO_BACK: float = 5.0

@export var movement_speed: float = 400.0
@export var dash_distance: float = 150.0
@export var dash_duration: float = 0.1
@export var dash_time_cost: int = 3
@export var health_component: HealthComponent
@export var attack_manager: AttackManager

var can_move: bool = true
var can_input: bool = true

var dash_direction: Vector2 = Vector2.ZERO
var starting_dash_pos: Vector2 = Vector2.ZERO
var final_dash_pos: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
#var can_dash: bool = true

var position_hp_queue: Array[PositionHPInfo] = []
var queue_update_time: float = SECONDS_TO_GO_BACK / MAX_QUEUE_SIZE
var queue_timer: float = 0.0
var can_recall: bool = true
var recall_cooldown: float = 15.0
var recall_on_cd: bool = false
var recall_elapsed_time: float = 0.0

# for the dash process and the recall
# make sure you check player has tomes unlocked


func _ready() -> void:
	SignalBus.on_trigger_player_spawn.connect(_on_spawn)
	add_to_group("player")
	
	GameUi.visible = true


func _physics_process(delta: float) -> void:
	if dash_timer > 0.0:
		dash_logic(delta)
	else:
		movement_input(delta)
	
	queue_timer += delta
	if queue_timer >= queue_update_time:
		queue_timer -= queue_update_time
		var pair: PositionHPInfo = PositionHPInfo.new(global_position, health_component.health)
		position_hp_queue.push_back(pair)
		if position_hp_queue.size() > MAX_QUEUE_SIZE:
			position_hp_queue.pop_front()
	
	if recall_on_cd:
		recall_elapsed_time += delta
		if recall_elapsed_time >= recall_cooldown:
			recall_on_cd = false
	
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
	if not can_input:
		return
	
	if (
			Input.is_action_just_pressed("recall") and position_hp_queue.size() == MAX_QUEUE_SIZE
			and can_recall and not recall_on_cd
	):
		recall()
	
	if Input.is_action_just_pressed("test"):
		TimeManager.toggle_clock_mode()
	
	if Input.is_action_just_pressed("test2"):
		TimeManager.is_paused = false


func dash(direction: Vector2) -> void:
	dash_direction = direction
	dash_timer = dash_duration
	starting_dash_pos = global_position
	final_dash_pos = global_position + (dash_direction * dash_distance)
	
	health_component.can_take_damage = false
	TimeManager.subtract_from_slot(Utility.TimeSlot.B, dash_time_cost)
	
	attack_manager.is_dashing = true
	if attack_manager.winding_up:
		attack_manager.windup_elapsed_time += dash_time_cost
	elif attack_manager.shot_on_cd:
		attack_manager.shot_elapsed_time += dash_time_cost


func dash_logic(delta: float) -> void:
	var dash_progress = 1.0 - (dash_timer / dash_duration)
	dash_progress = clamp(dash_progress, 0.0, 1.0)
	global_position = lerp(starting_dash_pos, final_dash_pos, dash_progress)
	
	# velocity should be max during and after the dash
	velocity = dash_direction * movement_speed
	
	dash_timer -= delta
	if dash_timer <= 0.0:
		dash_direction = Vector2.ZERO
		# probably want to add some frames after the dash where u cant take damage
		health_component.can_take_damage = true
		attack_manager.is_dashing = false


func recall() -> void:
	recall_on_cd = true
	
	can_move = false
	health_component.can_take_damage = false
	attack_manager.freeze_cds = true
	
	var array: Array[PositionHPInfo] = position_hp_queue
	position_hp_queue = []
	
	var wait_time: float = max(0.05, 1.0 / MAX_QUEUE_SIZE)
	for i in range(array.size() - 1, -1, -1):
		await get_tree().create_timer(wait_time).timeout
		global_position = array[i].position
		health_component.health = array[i].health
	
	TimeManager.add_to_slot(Utility.TimeSlot.B, SECONDS_TO_GO_BACK)
	attack_manager.winding_up = false
	attack_manager.shot_on_cd = false
	attack_manager.shot_elapsed_time = 0.0
	
	can_move = true
	health_component.can_take_damage = true
	attack_manager.freeze_cds = false


func _on_spawn(spawn_position: Vector2, spawn_direction: String) -> void:
	global_position = spawn_position
	# do some stuff with spawn direction here
