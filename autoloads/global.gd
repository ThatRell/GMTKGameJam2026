extends Node

var game_data: GameData


func _ready() -> void:
	game_data = GameData.new()
	# testing stuff
	#game_data.unlocked_spells["TimeDash"] = true
	#game_data.unlocked_spells["TimeStop"] = true
	#game_data.unlocked_spells["TimeRecall"] = true
