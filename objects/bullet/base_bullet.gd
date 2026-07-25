class_name BaseBullet
extends Area2D

var speed: float = 170.0
var damage: float = 10.0
var life_time: float = 20.0
var frozen: int = 0

@onready var timer: SceneTreeTimer = get_tree().create_timer(life_time)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	body_entered.connect(_on_body_entered)
	timer.timeout.connect(_on_bullet_timeout)


func _process(delta: float) -> void:
	if frozen < 0:
		frozen = 0


func _physics_process(delta: float) -> void:
	if frozen > 0:
		return
	
	global_position += Vector2.RIGHT.rotated(global_rotation) * speed * delta


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		#print("damaged")
		var hitbox: HitboxComponent = area
		hitbox.damage(damage)
		
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	#print("hit a wall")
	queue_free()


func _on_bullet_timeout() -> void:
	#print("bullet memory freed")
	queue_free()
