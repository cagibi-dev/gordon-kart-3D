extends VehicleBody

signal shoot

onready var start_pos := transform
onready var drift_sound: AudioStreamPlayer3D = $Drift
onready var engine_sound: AudioStreamPlayer = $Engine
onready var speed_label: Label3D = $Speed
onready var wheels: Array = [$WheelFL, $WheelFR, $WheelBL, $WheelBR]

var is_player := true


func _physics_process(delta: float) -> void:
	# steer
	var steering_target = Input.get_axis("move_right", "move_left")
	steering = lerp(steering, steering_target, 2 * delta)

	# get acceleration input
	var acc := Input.get_axis("reverse", "accelerate")
	# calculate speed in m/s
	var vel: float = (wheels[0].get_rpm() + wheels[1].get_rpm()) / 48

	# if going pretty fast and reverse: brake
	if acc < 0 and vel > 0.5:
		brake = 200
		acc = 0
	else:
		brake = 0

	var play_drift := false
	for wheel in wheels:
		if wheel.get_skidinfo() < 0.5:
			play_drift = true
	if play_drift and not drift_sound.playing:
		drift_sound.play()
	if not play_drift and drift_sound.playing:
		drift_sound.stop()

	speed_label.text = str(floor(abs(vel) * 3.6)) + " km/h"
	# accelerate according to gear
	if abs(vel) < 6:
		engine_force = 3600 * acc
	elif abs(vel) < 12:
		engine_force = 1800 * acc
	else:
		engine_force = 1200 * acc

	# modulate engine sound
	if acc:
		engine_sound.pitch_scale = 0.5 + abs(vel) / 18.0
	else:
		engine_sound.pitch_scale = lerp(engine_sound.pitch_scale, 0.5, delta)

	# Respawn if out of bounds or self-destructing
	if translation.y < -20:
		respawn()


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("jump"):
		jump()
	if event.is_action_pressed("shoot"):
		emit_signal("shoot")


func respawn():
	transform = start_pos
	linear_velocity = Vector3()


func boost(amount: float):
	linear_velocity += linear_velocity.normalized() * amount


func jump():
	linear_velocity *= 1.6
	set_axis_velocity(Vector3(0, 4, 0))


func _on_NetworkUpdateTimer_timeout():
	if not Lobby.player_info.empty():
		rpc("move_player", transform, { "playing": engine_sound.playing, "pitch": engine_sound.pitch_scale })


remote func move_player(transform: Transform, engine: Dictionary):
	var id = get_tree().get_rpc_sender_id()
	# print("player ", id, " has moved to ", transform)
	Lobby.update_car(id, transform, engine)
