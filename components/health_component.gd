class_name HealthComponent
extends Node2D

signal died

@export var max_health: float = 100.0

var health: float
var can_take_damage: bool = true


func _ready() -> void:
	health = max_health


func damage(amount: float):
	health -= amount
	
	if health <= 0:
		died.emit()
		#queue_free() # <- will have to happen in wtv function the died signal connects to
