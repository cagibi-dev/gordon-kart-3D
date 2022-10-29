extends VehicleBody


var music_filter: AudioEffectLowPassFilter
var engine_filter: AudioEffectHighPassFilter
onready var start_pos := transform
onready var brake_sound: AudioStreamPlayer3D = $Brake
onready var engine_sound: AudioStreamPlayer = $Engine
onready var speed_label: Label = $Speed
onready var wheel1: VehicleWheel = $WheelFL
onready var wheel2: VehicleWheel = $WheelFR

var is_player := true


func _ready():
	music_filter = AudioServer.get_bus_effect(1, 0)
	engine_filter = AudioServer.get_bus_effect(3, 0)
	AudioServer.set_bus_effect_enabled(1, 0, false)


func _physics_process(delta: float) -> void:
	# steer
	var steering_target = Input.get_axis("move_right", "move_left")
	steering = lerp(steering, steering_target, 2 * delta)

	# brake
	brake = 50 * Input.get_action_strength("brake")
	if brake and wheel1.get_rpm() > 10 and wheel1.is_in_contact() \
		and wheel2.get_rpm() > 10 and wheel2.is_in_contact():
		if not brake_sound.playing:
			brake_sound.play()
	elif brake_sound.playing:
		brake_sound.stop()

	# accelerate according to gear
	var acc := Input.get_axis("accelerate_backwards", "accelerate")

	if acc != 0 and not engine_sound.playing:
		engine_sound.play()
	if acc == 0 and engine_sound.playing:
		engine_sound.stop()

	var vel: float = abs(wheel1.get_rpm() + wheel2.get_rpm()) / 48
	speed_label.text = str(floor(vel*3.6)) + " km/h"
	music_filter.cutoff_hz = min(500 + 400 * vel, 22050)
	if vel < 6:
		engine_force = 3600 * acc
	elif vel < 12:
		engine_force = 1800 * acc
	else:
		engine_force = 1200 * acc
	engine_sound.pitch_scale = 0.5+vel/18.0

	# Respawn if out of bounds or self-destructing
	if translation.y < -20:
		respawn()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		respawn()


func respawn():
	transform = start_pos


func boost(amount: float):
	linear_velocity += linear_velocity.normalized() * amount


func _on_NetworkUpdateTimer_timeout():
	if is_player and not Lobby.player_info.empty():
		rpc("move_player", transform)


remote func move_player(transform: Transform):
	var id = get_tree().get_rpc_sender_id()
	# print("player ", id, " has moved to ", transform)
	Lobby.update_car(id, transform)
