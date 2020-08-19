extends KinematicBody

export (float) var full_thrust := 20.0
export (float) var steer_angle := 4.0
var thrust := 0.0
var steering := 0.0
var velocity := Vector3.ZERO
var gravity := 20.0
var jump_speed := 10.0
var music_filter: AudioEffectLowPassFilter

func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)

func _input(event):
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_speed
		$Jump.play()

func _physics_process(delta):
	velocity.y -= gravity * delta

	var input_vec := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("accelerate") - Input.get_action_strength("brake"))
	
	thrust = lerp(thrust, full_thrust * input_vec.y, 0.2)
	steering = lerp(steering, steer_angle * input_vec.x, 0.1)
	var ideal_vel = Vector3.FORWARD.rotated(Vector3.UP, rotation.y) * thrust
	velocity.x = lerp(velocity.x, ideal_vel.x, 0.02)
	velocity.z = lerp(velocity.z, ideal_vel.z, 0.02)
	rotate_y(-steering * delta)

	if input_vec.y != 0:
		if not $Engine.playing:
			$Engine.play()
			$BackChassis/Bell3/Particles.emitting = true
			$BackChassis/Bell4/Particles2.emitting = true
		$Engine.pitch_scale = 0.2+0.1*velocity.length()
	if input_vec.y == 0 and $Engine.playing:
		$Engine.stop()
		$BackChassis/Bell3/Particles.emitting = false
		$BackChassis/Bell4/Particles2.emitting = false

	music_filter.cutoff_hz = min(500 + 50 * velocity.length_squared(), 22000)

	velocity = move_and_slide(velocity, Vector3.UP)
