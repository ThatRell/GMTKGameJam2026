class_name TimeBubble
extends Area2D

var frozen_bodies: Array[Enemy] = []
var frozen_areas: Array[BaseBullet] = []
var blank_duration: float = 2.5
var expired: bool = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _physics_process(delta: float) -> void:
	if not animation_player.is_playing():
		animation_player.play("bubble_idle")
	
	if expired:
		return
	
	freeze_bodies()
	freeze_areas()
	
	blank_duration -= delta
	if blank_duration <= 0:
		expired = true
		animation_player.play_backwards("bubble_form")
		await animation_player.animation_finished
		unfreeze()
		queue_free()


func freeze_bodies() -> void:
	var bodies: Array[Node2D] = get_overlapping_bodies()
	for body: Node2D in bodies:
		if not (body is Enemy):
			continue
		 
		var enemy: Enemy = body as Enemy
		if enemy.is_queued_for_deletion() or enemy in frozen_bodies:
			continue
		
		frozen_bodies.append(enemy)
		enemy.frozen += 1


func freeze_areas() -> void:
	var areas: Array[Area2D] = get_overlapping_areas()
	for area: Area2D in areas:
		if not (area is BasicEnemyBullet):
			continue
		
		var bullet: BasicEnemyBullet = area as BasicEnemyBullet
		if bullet.is_queued_for_deletion() or bullet in frozen_areas:
			continue
		
		frozen_areas.append(bullet)
		bullet.frozen += 1


func unfreeze() -> void:
	for enemy: Enemy in frozen_bodies:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			enemy.frozen -= 1
	
	for bullet: BasicEnemyBullet in frozen_areas:
		if is_instance_valid(bullet) and not bullet.is_queued_for_deletion():
			bullet.frozen -= 1
