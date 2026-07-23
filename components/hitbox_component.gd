class_name HitboxComponent
extends Area2D

@export var health_component: HealthComponent


func damage(amount: float):
	if health_component and health_component.can_take_damage:
		health_component.damage(amount)
