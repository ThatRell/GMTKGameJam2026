class_name BaseBullet
extends Area2D

var speed: float = 250.0
var damage: float = 10.0
var life_time: float = 10.0


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(life_time).timeout.connect(_on_bullet_timeout)


func _physics_process(delta: float) -> void:
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var hitbox: HitboxComponent = area
		hitbox.damage(damage)
		
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	queue_free()


func _on_bullet_timeout() -> void:
	#print("bullet memory freed")
	queue_free()
