extends CharacterBody3D

const SPEED = 10.0
const DASH_SPEED = 60.0
const DASH_TIME = 0.1  # Adjust as needed

var gravity = 4 * ProjectSettings.get_setting("physics/3d/default_gravity")
var is_dashing = false
var dash_timer = 0.0

func _physics_process(delta):
	if not is_dashing:
		handle_movement(delta)
	else:
		handle_dash(delta)

func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		start_dash()

	move_and_slide()

func handle_dash(delta):
	dash_timer -= delta
	if dash_timer <= 0.0:
		end_dash()

	# Apply dash velocity
	velocity = velocity.normalized() * DASH_SPEED

	move_and_slide()

func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME

func end_dash():
	is_dashing = false
	velocity = Vector3.ZERO

func die():
	print("player dead, restarting game")
	get_tree().reload_current_scene()
