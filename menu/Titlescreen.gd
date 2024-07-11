extends Node


func _on_PlaySolo_pressed():
	$MainPanel.hide()
	go_to_lobby()


func _on_PlayMulti_pressed():
	$Next.play()
	create_tween().tween_property($MainPanel, "rotation", PI, 0.2)
	$PlayOnline.show()
	$PlayOnline.rotation = PI
	create_tween().tween_property($PlayOnline, "rotation", 0, 0.2)
	$PlayOnline/Username.grab_focus()


func _on_MoreGames_pressed():
	var err := OS.shell_open("https://cagibi.itch.io")
	assert(err == OK)


func _on_Host_pressed():
	$PlayOnline.hide()
	Globals.multi_manager.host($PlayOnline/Username.text, int($PlayOnline/Port.text))
	go_to_lobby()


func _on_Join_pressed():
	$PlayOnline.hide()
	Globals.multi_manager.join($PlayOnline/Username.text, $PlayOnline/IP.text, int($PlayOnline/Port.text))
	go_to_lobby()


func go_to_lobby():
	$Next.play()
	for i in range(10):
		$Camera.rotation.x = 0.05 * pow(-1, i)
		yield(get_tree(), "physics_frame")
	$Camera.rotation.z = 0
	yield(get_tree().create_timer(0.2), "timeout")

	var err := get_tree().change_scene_to(preload("res://circuits/Lobby.tscn"))
	assert(err == OK)
