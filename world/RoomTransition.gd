extends Area


export (String, FILE, "*.tscn") var destination := "res://circuits/Lobby.tscn"


func _on_body_entered(_body):
	var err := get_tree().change_scene(destination)
	assert(err == OK)
