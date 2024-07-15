extends Node


onready var multi_manager: MultiManager = $MultiManager

var playlist := [
	[null, "silence"],
	[preload("res://music/gordon-funk-loop-deluxe.ogg"), "Gordon Funk Loop (cagibidev)"],
	[preload("res://music/Buster_Prototype_Fluidvolt.ogg"), "Buster Prototype (© Fluidvolt)"],
	[preload("res://music/Rocket_Glider_Fluidvolt.ogg"), "Rocket Glider (© Fluidvolt)"],
	[preload("res://music/urbania.ogg"), "Urbania (CC-BY Dan Knoflicek)"],
	[preload("res://music/Viktor Kraus - Well oiled, shiny Oscillators.ogg"), "Well oiled, shiny Oscillators (CC-BY Viktor Kraus)"],
	[preload("res://music/Funked Up.ogg"), "Funked Up (CC0 Joth)"],
	[preload("res://music/jazzy-blues.ogg"), "Jazzy Blues (CC0 LushoGames)"],
	[preload("res://music/Funkorama.ogg"), "Funkorama (CC-BY Kevin MacLeod)"],
	[preload("res://music/pompy_lowres.ogg"), "Pompy by Hubert Lamontagne"],
]
var current_song := 0

var env_list := [
	preload("res://world/environments/env_sunset.tres"),
	preload("res://world/environments/env_night.tres"),
	preload("res://world/environments/env_day.tres"),
	preload("res://world/environments/env_low_perf.tres"),
]
var current_env := 0


func _ready():
	yield(get_tree(), "idle_frame")
	$TestSound.stop()


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


func _on_NextEnv_pressed():
	current_env += 1
	if current_env >= len(env_list):
		current_env = 0

	$Env.environment = env_list[current_env]
	push_msg("Time set to " + ["sunset", "night", "day", "low-perf"][current_env])
	make_everything_unshaded(current_env == 3)

	if get_tree().current_scene is Circuit:
		var level := (get_tree().current_scene as Circuit)
		level.setup_env(current_env)


func make_everything_unshaded(unshaded := true):
	#$SunLight.visible = not unshaded
	var mats := [
		preload("res://items/barrel/barrel.material"),
		preload("res://vehicles/car6_mat.material"),
		preload("res://materials/Grey.material"),
		preload("res://materials/Red.material"),
		preload("res://materials/White.material"),
		preload("res://materials/gilded.material"),
		preload("res://materials/scales.material"),
		preload("res://urbankit/asphalt.material"),
		preload("res://urbankit/concrete.material"),
		preload("res://urbankit/concreteSmooth.material"),
		preload("res://urbankit/dirt.material"),
		preload("res://urbankit/doors.material"),
		preload("res://urbankit/grass2.material"),
		preload("res://urbankit/metal.material"),
		preload("res://urbankit/roof.material"),
		preload("res://urbankit/roof_plates.material"),
		preload("res://urbankit/treeA.material"),
		preload("res://urbankit/treeB.material"),
		preload("res://urbankit/truck.material"),
		preload("res://urbankit/truck_alien.material"),
		preload("res://urbankit/wall.material"),
		preload("res://urbankit/wall_garage.material"),
		preload("res://urbankit/wall_lines.material"),
		preload("res://urbankit/wall_metal.material"),
		preload("res://materials/pizza.material"),
	]
	for mat in mats:
		assert(mat is Material3D)
		mat.set_flag(0, unshaded)
	var mat: ShaderMaterial = preload("res://materials/terrain_blend.material")
	if unshaded:
		mat.shader = preload("res://world/procgen_terrain_unshaded.gdshader")
	else:
		mat.shader = preload("res://world/procgen_terrain.gdshader")
