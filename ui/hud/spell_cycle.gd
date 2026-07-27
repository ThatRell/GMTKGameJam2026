extends Control

@onready var label: Label = %Label
@onready var timer: Timer = $Timer

var current_spell_name: String


func _ready() -> void:
	visible = false
	timer.timeout.connect(on_timer_timeout)
	SignalBus.on_current_spell_updated.connect(update)


func reset() -> void:
	label.text = ""


func update(spell_name: String) -> void:
	if current_spell_name == spell_name:
		return
	
	current_spell_name = spell_name
	visible = true
	label.text = "Current Attack Spell: " + spell_name
	timer.start()


func on_timer_timeout() -> void:
	visible = false
