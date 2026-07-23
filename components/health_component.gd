class_name HealthComponent
extends Node2D

@export var max_health: float = 100.0

var health: float
var can_take_damage: bool = true


func _ready() -> void:
	health = max_health


func damage(amount: float):
	health -= amount
	
	if health <= 0:
		var parent = get_parent()
		if parent is Player:
			pass
			# idk i can do something here maybe
			# like a signal or something
		else:
			parent.queue_free()
