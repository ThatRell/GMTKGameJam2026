class_name Player
extends CharacterBody2D

const TIME_BUBBLE_SCENE: PackedScene = preload("uid://dx44d5k2eekbd")
const MOVEMENT_ACCELERATION: float = 22.0
const MAX_QUEUE_SIZE: int = 20
const SECONDS_TO_GO_BACK: float = 7.0
const DASH_MULTIPLIER: float = 1.4

@export var movement_speed: float = 100.0
@export var dash_duration: float = 0.1
@export var dash_time_cost: int = 3
@export var health_component: HealthComponent
@export var attack_manager: AttackManager

var can_move: bool = true
var can_input: bool = true

var dash_direction: Vector2 = Vector2.ZERO
var dash_timer: float = 0.0
var dash_speed: float = 300.0
var can_dash: bool = true
var dash_cooldown: float = 1.3
var dash_on_cd: bool = false
var dash_elapsed_time: float = 0.0

var position_hp_queue: Array[PositionHPInfo] = []
var queue_update_time: float = SECONDS_TO_GO_BACK / MAX_QUEUE_SIZE
var queue_timer: float = 0.0
var can_recall: bool = true
var recall_cooldown: float = 13.0
var recall_on_cd: bool = false
var recall_elapsed_time: float = 0.0

var can_blank: bool = true
var blank_cooldown: float = 7.0
var blank_on_cd: bool = false
var blank_cd_elapsed_time: float = 0.0

# for the dash process, recall, and time stop
# make sure you check player has tomes unlocked

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D


func _ready() -> void:
	SignalBus.on_trigger_player_spawn.connect(_on_spawn)
	add_to_group("player")
	
	health_component.died.connect(on_player_died)
	
	GameUi.visible = true


func _process(delta: float) -> void:
	if recall_on_cd:
		recall_elapsed_time += delta
		if recall_elapsed_time >= recall_cooldown:
			recall_on_cd = false
	
	if blank_on_cd:
		blank_cd_elapsed_time += delta
		if blank_cd_elapsed_time >= blank_cooldown:
			blank_on_cd = false
	
	if dash_on_cd:
		dash_elapsed_time += delta
		if dash_elapsed_time >= dash_cooldown:
			dash_on_cd = false
	
	non_movement_input(delta)


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
	
	handle_animations()
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
	
	if (
			Input.is_action_just_pressed("dash") and Global.game_data.unlocked_time_dash 
			and can_dash and not dash_on_cd
	):
		if input_vector != Vector2.ZERO:
			dash(input_vector) # based on player input
		elif velocity.length() > 0.15:
			dash(velocity.normalized()) # else default on if there's velocity in a direction
	
	if velocity.length() <= 0.15:
		velocity = Vector2.ZERO


func non_movement_input(delta: float) -> void:
	if not can_input:
		return
	
	if (
			Input.is_action_just_pressed("recall") and Global.game_data.unlocked_time_recall
			and position_hp_queue.size() == MAX_QUEUE_SIZE and can_recall and not recall_on_cd
	):
		recall()
	
	if (
			Input.is_action_just_pressed("blank") and Global.game_data.unlocked_time_stop
			and can_blank and not blank_on_cd
	):
		blank()


func dash(direction: Vector2) -> void:
	dash_on_cd = true
	dash_elapsed_time = 0.0
	
	dash_direction = direction
	dash_timer = dash_duration
	
	health_component.can_take_damage = false
	if TimeManager.clock_mode == Utility.ClockMode.MSM:
		TimeManager.subtract_from_slot(Utility.TimeSlot.B, dash_time_cost)
	else:
		TimeManager.subtract_from_slot(Utility.TimeSlot.C, dash_time_cost)
	
	attack_manager.is_dashing = true
	if attack_manager.winding_up:
		attack_manager.windup_elapsed_time += dash_time_cost
	elif attack_manager.shot_on_cd:
		attack_manager.shot_elapsed_time += dash_time_cost


func dash_logic(delta: float) -> void:
	#var dash_progress = 1.0 - (dash_timer / dash_duration)
	#dash_progress = clamp(dash_progress, 0.0, 1.0)
	#var current_speed = lerp(dash_speed, dash_speed * 0.5, dash_progress)
	
	# velocity should be max during and after the dash
	velocity = dash_direction * movement_speed * dash_time_cost * DASH_MULTIPLIER
	
	dash_timer -= delta
	if dash_timer <= 0.0:
		dash_direction = Vector2.ZERO
		# probably want to add some frames after the dash where u cant take damage
		health_component.can_take_damage = true
		attack_manager.is_dashing = false


func recall() -> void:
	recall_on_cd = true
	recall_elapsed_time = 0.0
	
	can_move = false
	can_blank = false
	health_component.can_take_damage = false
	attack_manager.freeze_cds = true
	
	var array: Array[PositionHPInfo] = position_hp_queue
	position_hp_queue = []
	
	var wait_time: float = max(0.05, 1.0 / MAX_QUEUE_SIZE)
	for i in range(array.size() - 1, -1, -1):
		await get_tree().create_timer(wait_time).timeout
		global_position = array[i].position
		health_component.health = array[i].health
	
	if TimeManager.clock_mode == Utility.ClockMode.MSM:
		TimeManager.add_to_slot(Utility.TimeSlot.B, SECONDS_TO_GO_BACK)
	else:
		TimeManager.add_to_slot(Utility.TimeSlot.C, SECONDS_TO_GO_BACK)
	attack_manager.winding_up = false
	attack_manager.shot_on_cd = false
	attack_manager.shot_elapsed_time = 0.0
	
	can_move = true
	can_blank = true
	health_component.can_take_damage = true
	attack_manager.freeze_cds = false


func blank() -> void:
	blank_on_cd = true
	blank_cd_elapsed_time = 0.0
	
	var new_bubble: TimeBubble = TIME_BUBBLE_SCENE.instantiate()
	new_bubble.global_position = global_position
	SignalBus.on_player_blanked.emit(new_bubble)


func handle_animations() -> void:
	if velocity:
		animation_player.play("walk_right")
	else:
		animation_player.play("idle_right")
	
	var direction: Vector2 = get_global_mouse_position() - global_position
	if direction.x >= 0:
		sprite_2d.flip_h = false
	else:
		sprite_2d.flip_h = true


func _on_spawn(spawn_position: Vector2, _spawn_direction: String) -> void:
	global_position = spawn_position


func on_player_died() -> void:
	print("your time was cut short.")
	# death animation here or something
	# await
	TimeManager.return_by_death()
