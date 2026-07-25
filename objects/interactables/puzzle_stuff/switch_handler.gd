extends Node

# lwk this node could just be the door and go into puzzle stuff
# like after both are active then it queue frees or something
@export var switch_one: TimedSwitch
@export var switch_two: TimedSwitch


func _process(delta: float) -> void:
	if (
		(switch_one.interactable and switch_two.interactable) and (switch_one.is_active and switch_two.is_active)
	):
		print("solved")
		switch_one.on_puzzle_completed()
		switch_two.on_puzzle_completed()
