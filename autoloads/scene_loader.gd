extends Node

signal load_finished

const MAIN_SCENES: Dictionary[String, StringName] = {
	"MainMenu": "uid://pxed7d8fqi64",
	"TestRoom": "uid://d2f6ud5xxium0",
	"Outside": "uid://bjvtncpmtk8hd",
	"Dungeon": "uid://b3n7ro0gs8pdk",
}

var loading_screen: PackedScene = preload("uid://77ubabpor8gs")
var entry_point: String = "" # for generic room script to move player to a place


func load_scene(scene_name: String) -> void:
	var scene_uid: String = MAIN_SCENES.get(scene_name)
	assert(scene_uid)
	
	var new_load_screen: CanvasLayer = loading_screen.instantiate()
	add_child(new_load_screen)
	load_finished.connect(new_load_screen._on_load_finished)
	
	await new_load_screen.loading_screen_ready
	
	var scene: PackedScene = load(scene_uid)
	get_tree().change_scene_to_packed(scene)
	load_finished.emit()
