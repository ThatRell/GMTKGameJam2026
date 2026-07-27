class_name HealthComponent
extends Node2D

signal died
signal took_damage

@export var max_health: float

var health: float
var can_take_damage: bool = true
var is_dead: bool = false


func _ready() -> void:
	set_max_health(max_health)


func damage(amount: float):
	if is_dead:
		return
	
	health -= amount
	var parent: Node = get_parent()
	if parent is Player:
		amount = amount as int
		SignalBus.on_player_lose_hp.emit(amount)
	
	took_damage.emit()
	
	if health <= 0:
		is_dead = true
		died.emit()
		#queue_free() # <- will have to happen in wtv function the died signal connects to


func set_max_health(hp: float):
	max_health = hp
	health = hp
