extends KinematicBody

export (float) var full_thrust := 25.0
export (float) var steer_angle := 2.0
var thrust := 0.0
var steering := 0.0
var velocity := Vector3.ZERO
var gravity := 20.0
var jump_speed := 10.0
var music_filter: AudioEffectLowPassFilter
var last_transform := Transform.IDENTITY  # respawn point
onready var engine_particles := [$Vehicle/BackChassis/BigLeftBell/Particles, $Vehicle/BackChassis/BigRightBell/Particles2]

func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)
	AudioServer.set_bus_effect_enabled(1, 0, false)
	$ThrustBar.max_value = full_thrust
	last_transform = transform

func _input(event):
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		$Jump.play()
		last_transform = transform

func reset():
	thrust = 0
	steering = 0
	velocity = Vector3.ZERO
	transform = last_transform
	$Dead.play()

func boost():
	thrust += 4

func _physics_process(delta):
	velocity.y -= gravity * delta

	if translation.y < -10:
		reset()

	var input_vec := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("accelerate"))

	var previous_thrust := thrust
	var previous_steering := steering
	
	steering = lerp(steering, steer_angle * input_vec.x, 0.1)

	if Input.is_action_pressed("brake"):
		thrust = lerp(thrust, 0, 0.05)
	else:
		thrust = lerp(thrust, full_thrust * input_vec.y, 0.01)
		thrust -= 1*abs(steering) * delta * sign(thrust)
	$ThrustBar.value = thrust
	var ideal_vel = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * thrust
	velocity.x = ideal_vel.x
	velocity.z = ideal_vel.z
	rotate_y(-steering * delta)
	
	# Drift effect
	$Vehicle.rotation.y = lerp_angle($Vehicle.rotation.y, -(steering)*0.2, 0.5)
	# Steering wheel turn
	$Vehicle/FrontChassis/SteeringWheel.rotation.y = -3*steering*delta

	if input_vec.y != 0:
		if not $Engine.playing:
			$Engine.play()
			for p in engine_particles:
				p.emitting = true
		$Engine.pitch_scale = 0.2+0.05*velocity.length()
	if input_vec.y == 0 and $Engine.playing:
		$Engine.stop()
		for p in engine_particles:
			p.emitting = false

	music_filter.cutoff_hz = min(500 + 50 * ideal_vel.length_squared(), 22000)

	velocity = move_and_slide(velocity, Vector3.UP, false, 4, 0.8, false)

	for i in get_slide_count():
		var collision := get_slide_collision(i)
		if collision.collider is RigidBody:
			collision.collider.apply_central_impulse(-collision.normal * 2)


func _on_World_finished():
	$AnimationPlayer.play("win")
	yield(get_tree().create_timer(3), "timeout")
	$AnimationPlayer.play("idle")
