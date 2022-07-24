extends VehicleBody


var music_filter: AudioEffectLowPassFilter
var engine_filter: AudioEffectHighPassFilter
onready var start_pos := transform


func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)
	engine_filter = AudioServer.get_bus_effect(3, 0)
	AudioServer.set_bus_effect_enabled(1, 0, false)


func _physics_process(delta: float) -> void:
	# steer
	var steering_target = Input.get_action_strength("move_left") - Input.get_action_strength("move_right")
	steering = lerp(steering, steering_target, 2 * delta)

	# brake
	brake = 50 * Input.get_action_strength("brake")
	if brake and ($WheelFL.get_rpm() > 10 and $WheelFL.is_in_contact()) and ($WheelFR.get_rpm() > 10 and $WheelFR.is_in_contact()):
		if not $Brake.playing:
			$Brake.play()
	elif $Brake.playing:
		$Brake.stop()

	# accelerate according to gear
	var acc := Input.get_action_strength("accelerate") - Input.get_action_strength("accelerate_backwards")

	if acc != 0 and not $Engine.playing:
		$Engine.play()
	if acc == 0 and $Engine.playing:
		$Engine.stop()

	var vel: float = abs($WheelFL.get_rpm() + $WheelFR.get_rpm()) / 48
	$Speed.text = str(floor(vel*3.6)) + " km/h"
	music_filter.cutoff_hz = min(500 + 400 * vel, 22000)
	if vel < 6:
		engine_force = 3600 * acc
	elif vel < 12:
		engine_force = 1800 * acc
	else:
		engine_force = 1200 * acc
	$Engine.pitch_scale = 0.5+vel/18.0

	# Respawn if out of bounds or self-destructing
	if translation.y < -20:
		respawn()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		respawn()


func respawn():
	transform = start_pos
	get_parent().can_finish = false # FIXME


func boost(amount: float):
	linear_velocity += linear_velocity.normalized() * amount
