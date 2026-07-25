class_name HealthComponent
extends Node2D

signal died

@export var max_health: float = 100.0

var health: float
var can_take_damage: bool = true
var is_dead: bool = false


func _ready() -> void:
	health = max_health


func damage(amount: float):
	if is_dead:
		return
	
	health -= amount
	
	if health <= 0:
		is_dead = true
		died.emit()
		#queue_free() # <- will have to happen in wtv function the died signal connects to
