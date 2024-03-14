extends Node

class_name HeartRateManager

signal difficulty_decreased(value)
signal difficulty_increased(value)

var difficulty = 5

func _on_heart_rate_monitor_hr_high_for_too_long():
	decrease_difficulty()

func _on_heart_rate_monitor_hr_low_for_too_long():
	increase_difficulty()

func _on_heart_rate_monitor_hr_went_above_high_threshold():
	pass # Replace with function body.

func _on_heart_rate_monitor_hr_went_below_low_threshold():
	pass # Replace with function body.

func decrease_difficulty():
	difficulty -= 1
	emit_signal("difficulty_decreased", difficulty)

func increase_difficulty():
	difficulty += 1
	emit_signal("difficulty_increased", difficulty)
