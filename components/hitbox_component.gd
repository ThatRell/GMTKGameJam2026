class_name HitboxComponent
extends Area2D

const EXTRA_REACT_TIME: float = 0.15

@export var health_component: HealthComponent


func damage(amount: float):
	if health_component and health_component.can_take_damage:
		
		if get_parent() is Player:
			await get_tree().create_timer(EXTRA_REACT_TIME).timeout
			if not health_component.can_take_damage:
				return
		
		health_component.damage(amount)
