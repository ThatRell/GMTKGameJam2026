class_name InteractManager
extends Node2D

var interact_range: float = 30.0
var can_interact: bool = true


func _ready() -> void:
	pass # Replace with function body.


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") and can_interact:
		on_interact_pressed()


func on_interact_pressed() -> void:
	var nodes: Array[Node] = get_tree().get_nodes_in_group("interactable")
	
	for node: Node in nodes:
		if not (node is Interactable):
			continue
		
		var interactable: Interactable = node as Interactable
		var distance: float = global_position.distance_to(interactable.global_position)
		if distance > interact_range:
			continue
		
		interactable.interact()
