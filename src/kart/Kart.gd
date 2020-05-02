extends VehicleBody

export (float) var full_thrust := 120.0
export (float) var steer_angle := 0.4
var music_filter: AudioEffectLowPassFilter

func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)

func _physics_process(_delta):
	var input_vec := Vector2(Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("accelerate") - Input.get_action_strength("brake"))
	
	engine_force = lerp(engine_force, input_vec.y * -full_thrust, 0.2)
	steering = lerp_angle(steering, input_vec.x * -steer_angle, 0.2)

	if input_vec.y != 0:
		if not $Engine.playing:
			$Engine.play()
		$Engine.pitch_scale = 0.2+0.1*linear_velocity.length()
	if input_vec.y == 0 and $Engine.playing:
		$Engine.stop()

	music_filter.cutoff_hz = 500 + 50 * linear_velocity.length_squared()
	#if Input.is_action_just_pressed("ui_accept"):
	#	apply_central_impulse(Vector3.UP*200)
