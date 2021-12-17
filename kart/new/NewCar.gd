extends VehicleBody


var gear := 1 # 0 1 2 3 = R 1 2 3


func _physics_process(delta: float) -> void:
	# steer
	var steering_target = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	steering = lerp(steering, steering_target, 2*delta)

	# brake
	brake = 50 * Input.get_action_strength("brake")

	# accelerate according to gear
	var acc := Input.get_action_strength("accelerate")
	if acc > 0 and not $Engine.playing:
		$Engine.play()
	if acc == 0 and $Engine.playing:
		$Engine.stop()
	var vel := (linear_velocity * (transform.basis.x + transform.basis.z)).length()
	$Label.text = "SPEED: " + str(floor(vel*3.6)) + " km/h"
	match gear:
		0:
			if vel < 6:
				engine_force = -2500 * acc
				$Engine.pitch_scale = 0.5+vel/6.0
			else:
				engine_force = 0
				$Engine.pitch_scale = 1.5
		1:
			if vel < 6:
				engine_force = 2500 * acc
				$Engine.pitch_scale = 0.5+vel/6.0
			else:
				engine_force = 0
				$Engine.pitch_scale = 1.5
		2:
			if vel < 13:
				engine_force = 1200 * acc
				$Engine.pitch_scale = 0.5+vel/13.0
			else:
				engine_force = 0
				$Engine.pitch_scale = 1.5
		3:
			engine_force = 800 * acc
			$Engine.pitch_scale = 0.5+vel/18.0


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gear_down") and gear > 0:
		gear -= 1
	if event.is_action_pressed("gear_up") and gear < 3:
		gear += 1
	$Gear.text = "GEAR: " + str(gear)
