extends "res://vehicles/NewCar.gd"


onready var remote_engine_sound: AudioStreamPlayer3D = $RemoteEngine


func _init():
	is_player = false
	set_physics_process(false)
