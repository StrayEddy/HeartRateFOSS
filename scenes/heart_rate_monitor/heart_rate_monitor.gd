extends Node

signal hr_high_for_too_long
signal hr_low_for_too_long
signal hr_went_above_high_threshold
signal hr_went_below_low_threshold

@export var time_allowed_at_low : int = 20
@export var time_allowed_at_high : int = 5

@export var low_hr_threshold : int = 68
@export var high_hr_threshold : int = 75

var hr_array : Array = [80]

#func _ready():
	#var thread = Thread.new()
	#var output = thread.start(_thread_function)
	#print("thread output: " + str(output))
#
#func _thread_function():
	#var output = []
	#OS.execute("gnome-terminal", ["--bash", "-c", "'cd scenes/heart_rate_sensor && expect -f ./heart_rate_sensor.expect'"], output)

# Get average hr in the last n seconds
func get_average_hr(in_last_n_seconds : int = 60) -> int:
	var sum : int = 0
	var num_elements : int = min(hr_array.size(), in_last_n_seconds)
	for i in range(num_elements):
		sum += hr_array[i]

	var average_hr : int = sum / num_elements
	return average_hr

func get_hr() -> int:
	return int(hr_array[0])

func get_previous_hr() -> int:
	if hr_array.size() > 1:
		return hr_array[1]
	else:
		return 0

func _process(delta : float) -> void:
	read_hr_from_file()

func check_hr_conditions() -> void:
	if get_hr() > high_hr_threshold:
		if get_average_hr(time_allowed_at_high) > high_hr_threshold:
			emit_signal("hr_high_for_too_long")
	elif get_hr() < low_hr_threshold:
		if get_average_hr(time_allowed_at_low) < low_hr_threshold:
			emit_signal("hr_low_for_too_long")
	
	var previous_hr : int = get_previous_hr()
	if previous_hr:
		if previous_hr < high_hr_threshold and get_hr() > high_hr_threshold:
			emit_signal("hr_went_above_high_threshold")
		elif previous_hr > low_hr_threshold and get_hr() < low_hr_threshold:
			emit_signal("hr_went_below_low_threshold")

func read_hr_from_file() -> void:
	# Read file content
	var hr_value = FileAccess.get_file_as_string("res://scenes/heart_rate_sensor/captured_values.txt")
	if hr_value != "":
		print("============")
		print(hr_value)
		hr_array.push_front(int(hr_value))
		# Clear file content
		var file = FileAccess.open("res://scenes/heart_rate_sensor/captured_values.txt", FileAccess.WRITE)
		file.flush()
		file.close()
		check_hr_conditions()
