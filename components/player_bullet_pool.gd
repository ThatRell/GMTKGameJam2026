class_name PlayerBulletPool
extends Node2D


func _ready() -> void:
	SignalBus.on_player_bullet_shot.connect(_add_bullet)


func _add_bullet(bullet: BaseBullet) -> void:
	add_child(bullet)
