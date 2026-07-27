class_name HitboxComponent
extends Area2D

signal player_dodge_result

const EXTRA_REACT_TIME: float = 0.075
const TERRAIN_HAZARD_DAMAGE: float = 50.0
const TERRAIN_HAZARD_DAMAGE_PLAYER: int = 2

@export var health_component: HealthComponent

var can_get_hit: bool = true


func damage(amount: float):
	if can_get_hit and health_component and health_component.can_take_damage:
		
		if get_parent() is Player:
			await get_tree().create_timer(EXTRA_REACT_TIME).timeout
			if not health_component.can_take_damage:
				print("saved by extra time")
				player_dodge_result.emit(true)
				return
			player_dodge_result.emit(false)
		
		health_component.damage(amount)


func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is TileMapLayer:
		if get_parent() is Player:
			damage(TERRAIN_HAZARD_DAMAGE_PLAYER)
		else:
			damage(TERRAIN_HAZARD_DAMAGE)
