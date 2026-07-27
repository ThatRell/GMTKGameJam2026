extends Control

const MAX_HP: int = 5
const HEART_ICON: PackedScene = preload("uid://ckw6miw48djvd")
const FILLED_REGION: Rect2 = Rect2(Vector2(0, 0), Vector2(16, 16))
const EMPTY_REGION: Rect2 = Rect2(Vector2(32, 0), Vector2(16, 16))

var hp_array: Array[TextureRect] = []
var current_index: int


func _ready() -> void:
	SignalBus.on_player_lose_hp.connect(lose_hp_display)
	SignalBus.on_player_gain_hp.connect(gain_hp_display)
	SignalBus.reset_player_hp_bar.connect(reset)
	reset()


func lose_hp_display(num: int) -> void:
	for n: int in range(num):
		if current_index <= 0:
			reset()
			return
		
		var icon: TextureRect = hp_array[current_index]
		icon.texture.region = EMPTY_REGION
		current_index -= 1
	var player: Player = get_tree().get_first_node_in_group("player")
	assert(player.health_component.health == current_index + 1)


func gain_hp_display(num: int) -> void:
	for n: int in range(num):
		if current_index >= hp_array.size():
			reset()
			return
			
		current_index += 1
		var icon: TextureRect = hp_array[current_index]
		icon.texture.region = FILLED_REGION
	var player: Player = get_tree().get_first_node_in_group("player")
	assert(player.health_component.health == current_index + 1)


func reset() -> void:
	var player: Player = get_tree().get_first_node_in_group("player")
	var hp: int = 0
	if not player:
		hp = MAX_HP
	else:
		hp = player.health_component.health
	
	for icon: TextureRect in hp_array:
		icon.queue_free()
	hp_array.clear()
	
	for n: int in range(MAX_HP):
		var icon: TextureRect = HEART_ICON.instantiate()
		if n < hp:
			icon.texture.region = FILLED_REGION
		else:
			icon.texture.region = EMPTY_REGION
		add_child(icon)
		hp_array.append(icon)
	current_index = hp - 1
