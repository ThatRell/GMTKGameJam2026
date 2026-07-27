extends Node

const NUM_PLAYERS: int = 8

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_2d_players: Array[AudioStreamPlayer2D] = []

func _ready() -> void:
	add_child(music_player)
	
	for i: int in range(NUM_PLAYERS):
		var p: AudioStreamPlayer = AudioStreamPlayer.new()
		p.volume_db = -10.0
		add_child(p)
		sfx_players.append(p)
	
	for i: int in range(20):
		var p2d: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
		p2d.volume_db = -10.0
		p2d.max_distance = 800
		add_child(p2d)
		sfx_2d_players.append(p2d)


func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
	
	music_player.stream = stream
	music_player.play()


func play_sfx(stream: AudioStream):
	for p: AudioStreamPlayer in sfx_players:
		if not p.playing:
			p.stream = stream
			p.play()
			return


func play_sfx_2d(stream: AudioStream, pos: Vector2):
	for p: AudioStreamPlayer2D in sfx_2d_players:
		if not p.playing:
			p.stream = stream
			p.global_position = pos
			p.play()
			return
