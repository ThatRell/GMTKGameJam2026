extends Interactable

const SPELL_STATS: Dictionary[String, SpellStats] = {
	"PiercingBolt": preload("uid://1xry05d2fxf0"),
}

@export var spell_name: String


func _ready() -> void:
	if Global.game_data.unlocked_spells.get(spell_name, false):
		queue_free()
	
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interact()


func interact() -> void:
	Global.game_data.unlocked_spells[spell_name] = true
	var spell: SpellStats = SPELL_STATS.get(spell_name, null)
	if spell:
		Global.game_data.spell_array.append(spell)
	
	queue_free()
