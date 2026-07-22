class_name GameData
extends Resource

@export var current_room: StringName = &"" # should be uid
@export var current_room_id: String = "" # should be room name
@export var player_entry_point: String # where the player spawns in the current room
@export var room_data: Dictionary[String, RoomData] = {}
