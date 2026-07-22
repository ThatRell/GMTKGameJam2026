extends Label


func _ready() -> void:
	TimeManager.updated.connect(update_display)
	update_display()


func update_display() -> void:
	text = TimeManager.get_display_string()
