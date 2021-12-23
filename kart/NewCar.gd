extends VehicleBody


var gear := 1
var fuel := 100.0
var can_acc := true
var music_filter: AudioEffectLowPassFilter
onready var start_pos := transform


func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)
	AudioServer.set_bus_effect_enabled(1, 0, false)


func _physics_process(delta: float) -> void:
	# steer
	var steering_target = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	steering = lerp(steering, steering_target, 2*delta)

	# brake
	brake = 50 * Input.get_action_strength("brake")
	if brake and ($WheelFL.get_rpm() > 10 and $WheelFL.is_in_contact()) and ($WheelFR.get_rpm() > 10 and $WheelFR.is_in_contact()):
		if not $Brake.playing:
			$Brake.play()
	elif $Brake.playing:
		$Brake.stop()

	# accelerate according to gear
	var acc := Input.get_action_strength("accelerate") - Input.get_action_strength("accelerate_backwards")
	if not can_acc:
		acc = 0
	if fuel <= 0:
		acc = 0
		$Fuel.text = "OUT OF FUEL"
	else:
		fuel -= 0.8 * abs(acc) * delta
		$Fuel.text = "FUEL: " + str(round(fuel))

	if acc != 0 and not $Engine.playing:
		$Engine.play()
	if acc == 0 and $Engine.playing:
		$Engine.stop()

	var vel: float = abs($WheelFL.get_rpm() + $WheelFR.get_rpm()) / 48
	$Dashboard/Speed.text = str(floor(vel*3.6)) + " km/h"
	music_filter.cutoff_hz = min(500 + 400 * vel, 22000)
	match gear:
		1:
			if vel < 6:
				engine_force = 3200 * acc
			else:
				engine_force = 0
			$Engine.pitch_scale = 0.5+vel/6.0
		2:
			if vel < 13:
				engine_force = 1500 * acc
			else:
				engine_force = 0
				$Engine.pitch_scale = 1.5
			$Engine.pitch_scale = 0.5+vel/13.0
		3:
			engine_force = 1000 * acc
			$Engine.pitch_scale = 0.5+vel/18.0

	# Respawn if out of bounds or self-destructing
	if translation.y < -20:
		respawn()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("gear_down") and gear > 1:
		set_gear(gear - 1)
		$GearDown.play()

	if event.is_action_pressed("gear_up") and gear < 3:
		set_gear(gear + 1)
		$GearUp.play()

	if Input.is_action_pressed("reset"):
		respawn()


func set_gear(new_gear: int):
	gear = new_gear
	$Dashboard/G1.modulate.a = 1.0 if gear == 1 else 0.3
	$Dashboard/G2.modulate.a = 1.0 if gear == 2 else 0.3
	$Dashboard/G3.modulate.a = 1.0 if gear == 3 else 0.3
	# delay if gearing while accelerating (more interesting)
	if Input.is_action_pressed("accelerate"):
		can_acc = false
		yield(get_tree().create_timer(0.25), "timeout")
		can_acc = true


func respawn():
	transform = start_pos
	get_parent().can_finish = false # FIXME
	if fuel < 0.2:
		fuel = 10


func refuel(amount: int):
	fuel += amount
	if fuel > 100:
		fuel = 100


func boost(amount: float):
	linear_velocity += linear_velocity.normalized() * amount
