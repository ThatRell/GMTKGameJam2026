extends Interactable


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interact()


func interact() -> void:
	assert(Global.game_data)
	Global.game_data.unlocked_time_dash = true
	queue_free()
