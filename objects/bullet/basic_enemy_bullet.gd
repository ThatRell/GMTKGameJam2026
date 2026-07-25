class_name BasicEnemyBullet
extends BaseBullet

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	super._ready()


func _process(delta: float) -> void:
	super._process(delta)
	
	if frozen > 0:
		if animation_player.is_playing():
			animation_player.pause()
	else:
		animation_player.play("enemy_bullet_flying")
