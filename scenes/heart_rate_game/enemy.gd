extends Node3D

class_name Enemy

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 8.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _physics_process(delta):
	position.y -= gravity * delta
		
func _on_death_timer_timeout():
	die()

func _on_body_entered(body):
	if body.name == "Player":
		print("contact with player")
		body.die()
	die()

func die():
	$CollisionShape3D.disabled = true
	hide()
	queue_free()
