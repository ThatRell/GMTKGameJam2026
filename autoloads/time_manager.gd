extends Node

signal updated

var a: int = 24
var b: int = 24
var c: int = 24

var clock_mode := Utility.ClockMode.HMS
var is_paused: bool = true

var _accumulator: float = 0.0


func toggle_clock_mode() -> void:
	if clock_mode == Utility.ClockMode.HMS:
		# hms to msm
		clock_mode = Utility.ClockMode.MSM
		c = (c * 1000) / 60 # seconds to milliseconds
	else:
		# msm to hms
		clock_mode = Utility.ClockMode.HMS
		c = (c * 60) / 1000 # milliseconds to seconds
	
	_accumulator = 0.0
	updated.emit()


func _process(delta: float) -> void:
	if is_paused:
		return
	
	_accumulator += delta
	
	match clock_mode:
		Utility.ClockMode.HMS:
			while _accumulator >= 1.0:
				_accumulator -= 1.0
				_decrement_time()
				updated.emit()
		
		Utility.ClockMode.MSM:
			while _accumulator >= 0.001:
				_accumulator -= 0.001
				_decrement_time()
				updated.emit()


func _decrement_time() -> void:
	if a == 0 and b == 0 and c == 0:
		on_clock_finish()
		return
	
	c -= 1
	
	if c < 0:
		if clock_mode == Utility.ClockMode.HMS:
			c = 59
		else:
			c = 999
		b -= 1
	
	if b < 0:
		b = 59
		a -= 1
	
	if a < 0:
		a = 0
		b = 0
		c = 0


# add decreasing for a specfiic slot


func on_clock_finish() -> void:
	print("Death clock is done.")
	is_paused = true
	# death animation or something here
	# await
	#SceneChanger.gameover screen


func get_display_string() -> String:
	match clock_mode:
		Utility.ClockMode.HMS:
			return "ClockMode: HMS\n%02d:%02d:%02d" % [
				a,
				b,
				c,
			]
		Utility.ClockMode.MSM:
			return "ClockMode: MSM\n%02d:%02d:%02d" % [
				a,
				b,
				c,
			]
	
	return ""
