class_name HitboxComponent
extends Area2D

const EXTRA_REACT_TIME: float = 0.15
const TERRAIN_HAZARD_DAMAGE: float = 50.0

@export var health_component: HealthComponent


func damage(amount: float):
	if health_component and health_component.can_take_damage:
		
		if get_parent() is Player:
			await get_tree().create_timer(EXTRA_REACT_TIME).timeout
			if not health_component.can_take_damage:
				print("saved by extra time")
				return
		
		health_component.damage(amount)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		damage(TERRAIN_HAZARD_DAMAGE)
