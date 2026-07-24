extends Node

signal updated

var a: int = 6
var b: int = 0
var c: int = 0

var clock_mode := Utility.ClockMode.HMS
var is_paused: bool = false
var is_finished: bool = false

var _accumulator: float = 0.0


func set_clock(slot_a: int, slot_b: int, slot_c: int) -> void:
	a = slot_a
	b = slot_b
	c = slot_c
	clamp_clock()
	
	_accumulator = 0.0
	updated.emit()


func clamp_clock() -> void:
	a = max(a, 0)
	b = clampi(b, 0, 59)
	
	if clock_mode == Utility.ClockMode.HMS:
		c = clampi(c, 0, 59)
	else:
		c = clampi(c, 0, 999)


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
	if is_paused or is_finished:
		return
	
	_accumulator += delta
	
	match clock_mode:
		Utility.ClockMode.HMS:
			while _accumulator >= 1.0:
				_accumulator -= 1.0
				subtract_from_slot(Utility.TimeSlot.C, 1)
		
		Utility.ClockMode.MSM:
			while _accumulator >= 0.001:
				_accumulator -= 0.001
				subtract_from_slot(Utility.TimeSlot.C, 1)
	
	if a == 0 and b == 0 and c == 0:
		is_finished = true
		on_clock_finish()


# decreasing time for a slot
func subtract_from_slot(slot: int, amount: int) -> void:
	if amount < 0:
		return
	
	match slot:
		Utility.TimeSlot.A:
			a = max(a - amount, 0)
		
		Utility.TimeSlot.B:
			while amount > 0:
				if b >= amount:
					b -= amount
					amount = 0
				else:
					amount -= b
					b = 0
					if amount > 0:
						if a > 0:
							a -= 1
							b = 59
							amount -= 1
						else:
							break
		
		Utility.TimeSlot.C:
			var max_c = 59 if clock_mode == Utility.ClockMode.HMS else 999
			while amount > 0:
				if c >= amount:
					c -= amount
					amount = 0
				else:
					amount -= c
					c = 0
					if amount > 0:
						if b > 0:
							b -= 1
							c = max_c
							amount -= 1
						elif a > 0:
							a -= 1
							b = 59
							c = max_c
							amount -= 1
						else:
							break
	
	updated.emit()


# adding time to a slot
func add_to_slot(slot: int, amount: int) -> void:
	if amount < 0:
		return
	
	match slot:
		Utility.TimeSlot.A:
			a += amount
		Utility.TimeSlot.B:
			b += amount
			check_b_overflow()
		Utility.TimeSlot.C:
			var b_units: int
			if clock_mode == Utility.ClockMode.HMS:
				b_units = (c + amount) / 60
				b += b_units
				check_b_overflow()
				c = (c + amount) % 60
			else:
				b_units = (c + amount) / 1000
				b += b_units
				check_b_overflow()
				c = (c + amount) % 1000
	
	updated.emit()


func check_b_overflow() -> void:
	var a_units: int = b / 60
	a += a_units
	b %= 60


func on_clock_finish() -> void:
	print("Death clock is done.")
	is_paused = true
	# death animation or something here
	# await
	return_by_death()


func return_by_death() -> void:
	SceneLoader.entry_point = "Spawn"
	SceneLoader.load_scene("Outside")


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
