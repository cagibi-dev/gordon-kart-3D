extends Node2D


func _ready():
	var err := get_tree().connect("network_peer_connected", self, "connected")
	err += get_tree().connect("network_peer_disconnected", self, "disconnected")
	assert(err == OK)

	$Username.grab_focus()


func _on_CloseMulti_pressed():
	$Explode.play()
	$Popup.hide()
	$Username.hide()


func _on_Host_pressed():
	_on_CloseMulti_pressed()
	Lobby.my_info.name = $Username.text
	$Status.text = "STARTED SESSION AS " + Lobby.my_info.name

	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(23456, 20)
	get_tree().network_peer = peer


func _on_Join_pressed():
	_on_CloseMulti_pressed()
	Lobby.my_info.name = $Username.text
	$Status.text = "JOINED AS " + Lobby.my_info.name

	var peer = NetworkedMultiplayerENet.new()
	peer.create_client("localhost", 23456)
	get_tree().network_peer = peer


func connected(id: int):
	yield(get_tree().create_timer(0.2), "timeout")
	$Connected.play()
	$Status.text = str(Lobby.player_info[id].name) + " appears"


func disconnected(id: int):
	$Disconnected.play()
	$Status.text = str(Lobby.player_info[id].name) + " is destroyed"
