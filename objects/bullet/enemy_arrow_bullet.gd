extends BasicEnemyBullet


func _ready() -> void:
	super._ready()
	animation_player = $AnimationPlayer


func destroy() -> void:
	destroyed.emit()
	queue_free()
