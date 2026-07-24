class_name PlayerBulletPool
extends Node2D


func _ready() -> void:
	SignalBus.on_player_bullet_shot.connect(_add_bullet)
	SignalBus.on_player_blanked.connect(_add_time_bubble)


func _add_bullet(bullet: BaseBullet) -> void:
	add_child(bullet)


func _add_time_bubble(bubble: TimeBubble) -> void:
	add_child(bubble)
