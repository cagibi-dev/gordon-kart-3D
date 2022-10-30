# Typical lobby implementation; imagine this being in /root/lobby.

# see https://gotm.io/docs/multiplayer

extends Node

# Connect all functions

func _ready():
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
	# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
	# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
	# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")

# Player info, associate ID to data
var player_info = {}
# Info we send to other players
var my_info = { name = "Johnson Magenta", favorite_color = Color8(255, 0, 255) }

func _player_connected(id):
	# Called on both clients and server when a peer connects. Send my info to it.
	rpc_id(id, "register_player", my_info)


func _player_disconnected(id):
	yield(get_tree(), "idle_frame")
	remove_car(player_info[id])
	player_info.erase(id) # Erase player from info.

func _connected_ok():
	pass # Only called on clients, not server. Will go unused; not useful here.

func _server_disconnected():
	pass # Server kicked us; show error and abort.

func _connected_fail():
	pass # Could not even connect to server; abort.

remote func register_player(info):
	# Get the id of the RPC sender.
	var id = get_tree().get_rpc_sender_id()
	# Store the info
	player_info[id] = info

	add_car(info)


func add_car(info):
	var car := preload("res://vehicles/RemoteControlled.tscn").instance()
	add_child(car)
	info.car = car
	yield(get_tree().create_timer(0.5), "timeout")
	car.get_node("Username").text = info.name


func remove_car(info):
	info.car.queue_free()


func update_car(id, transform: Transform, engine: Dictionary):
	player_info[id].car.transform = transform
	player_info[id].car.remote_engine_sound.playing = engine.playing
	player_info[id].car.remote_engine_sound.pitch_scale = engine.pitch
