extends Interactable

const audio: AudioStream = preload("res://assets/sounds/pickupCoin.wav")
var player: Player


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body as Player
		interact()


func interact() -> void:
	if not player:
		return
	
	if player.health_component.health < player.health_component.max_health:
		player.health_component.health += 1
		SignalBus.on_player_gain_hp.emit(1)
		AudioManager.play_sfx(audio)
		queue_free()
