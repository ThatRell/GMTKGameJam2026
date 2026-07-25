class_name TimeBubble
extends Area2D

var frozen_bodies: Dictionary[Enemy, bool] = {}
var frozen_areas: Dictionary[BaseBullet, bool] = {}
var blank_duration: float = 2.0
var expired: bool = false


func _physics_process(delta: float) -> void:
	if expired:
		return
	
	freeze_bodies()
	freeze_areas()
	
	blank_duration -= delta
	if blank_duration <= 0:
		expired = true
		unfreeze()
		queue_free()


func freeze_bodies() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()
	for body: Node2D in bodies:
		if not (body is Enemy):
			continue
		 
		var enemy: Enemy = body as Enemy
		if frozen_bodies.has(enemy):
			continue
		frozen_bodies[enemy] = true
		enemy.health_component.died.connect(clear_invalid_enemies.bind(enemy))
		enemy.frozen += 1


func freeze_areas() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if not (area is BaseBullet):
			continue
		
		var bullet: BaseBullet = area as BaseBullet
		if frozen_areas.has(bullet):
			continue
		frozen_areas[bullet] = true
		bullet.destroyed.connect(clear_invalid_bullets.bind(bullet))
		bullet.frozen += 1


func unfreeze() -> void:
	for enemy: Enemy in frozen_bodies:
		if is_instance_valid(enemy):
			enemy.frozen -= 1
	
	for bullet: BaseBullet in frozen_areas:
		if is_instance_valid(bullet):
			bullet.frozen -= 1


func clear_invalid_bullets(bullet: BaseBullet):
	frozen_areas.erase(bullet)


func clear_invalid_enemies(enemy: Enemy):
	frozen_bodies.erase(enemy)
