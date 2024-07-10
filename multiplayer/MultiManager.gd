extends Node2D
class_name MultiManager


signal pushed_message(text)


func _ready():
	var err := get_tree().connect("network_peer_connected", self, "connected")
	assert(err == OK)
	err = get_tree().connect("network_peer_disconnected", self, "disconnected")
	assert(err == OK)


func host(username := "gordon", port := 8070):
	Lobby.my_info.name = username
	emit_signal("pushed_message", "You started session as " + username)

	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(port, 8)
	get_tree().network_peer = peer


func join(username := "gordon", ip := "127.0.0.1", port := 8070):
	Lobby.my_info.name = username
	emit_signal("pushed_message", "You joined as " + username)

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip, port)
	get_tree().network_peer = peer


func connected(id: int):
	yield(get_tree().create_timer(0.2), "timeout")
	$Connected.play()
	emit_signal("pushed_message", str(Lobby.player_info[id].name) + " joined the gang")


func disconnected(id: int):
	$Disconnected.play()
	emit_signal("pushed_message", str(Lobby.player_info[id].name) + " blew up")
