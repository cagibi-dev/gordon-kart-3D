extends Node


onready var multi_manager: MultiManager = $MultiManager

var playlist := [
	[null, "silence"],
	[preload("res://music/Buster_Prototype_Fluidvolt.ogg"), "Buster Prototype (© Fluidvolt)"],
	[preload("res://music/Rocket_Glider_Fluidvolt.ogg"), "Rocket Glider (© Fluidvolt)"],
	[preload("res://music/urbania.ogg"), "Urbania (CC-BY Dan Knoflicek)"],
	[preload("res://music/Viktor Kraus - Well oiled, shiny Oscillators.ogg"), "Well oiled, shiny Oscillators (CC-BY Viktor Kraus)"],
	[preload("res://music/Funked Up.ogg"), "Funked Up (CC0 Joth)"],
	[preload("res://music/jazzy-blues.ogg"), "Jazzy Blues (CC0 LushoGames)"],
	[preload("res://music/Funkorama.ogg"), "Funkorama (CC-BY Kevin MacLeod)"],
	[preload("res://music/pompy_lowres.ogg"), "Pompy by madbr"],
]
var current_song := 0


func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))
	$TestSound.play()


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))
	$TestSound.play()


func _on_MultiManager_pushed_message(text := ""):
	push_msg(text)


func push_msg(text := ""):
	$Status3.text = $Status2.text
	$Status2.text = $Status1.text
	$Status1.text = text


func _on_Shuffle_pressed():
	current_song += 1
	if current_song >= len(playlist):
		current_song = 0
	$Music.stop()
	$Music.stream = playlist[current_song][0]
	push_msg(playlist[current_song][1])
	$Music.play()
