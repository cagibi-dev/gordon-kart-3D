extends Node


func _on_PlaySolo_pressed():
	var err := get_tree().change_scene_to(preload("res://circuits/Lobby.tscn"))
	assert(err == OK)


func _on_PlayMulti_pressed():
	pass # Replace with function body.


func _on_MoreGames_pressed():
	var err := OS.shell_open("https://cagibi.itch.io")
	assert(err == OK)
