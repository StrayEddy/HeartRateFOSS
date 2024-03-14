extends Node3D

var enemy_scene = load("res://scenes/heart_rate_game/enemy.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_spawn_timer_timeout():
	randomize()
	var enemy :Enemy = enemy_scene.instantiate()
	$Enemies.add_child(enemy)
	enemy.scale = Vector3.ONE * 10
	enemy.global_position = Vector3(randf_range(-10.0, 10.0), 500.0, randf_range(-10.0, 10.0))
	
func _on_heart_rate_manager_difficulty_decreased(value):
	$SpawnTimer.wait_time = 1.0/value
	print("difficulty decreased to " + str(1.0/value))
	print($SpawnTimer.wait_time)

func _on_heart_rate_manager_difficulty_increased(value):
	$SpawnTimer.wait_time = 1.0/value
	print("difficulty increased to " + str(1.0/value))
	print($SpawnTimer.wait_time)
