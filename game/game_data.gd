class_name GameData
extends Resource

@export var cleared_areas: Dictionary[String, bool] = {}
@export var unlocked_spells: Dictionary[String, bool] = {}
@export var spell_array: Array[SpellStats] = []

@export var recall_puzzle_solved: bool = false


func reset_on_death() -> void:
	cleared_areas = {}
	unlocked_spells = {}
	spell_array = []
	
	recall_puzzle_solved = false
