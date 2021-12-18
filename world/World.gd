extends Spatial

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

var playlist := [
	[null, "silence"],
	[preload("res://music/Buster_Prototype_Fluidvolt.ogg"), "Buster Prototype (© Fluidvolt)"],
	[preload("res://music/Rocket_Glider_Fluidvolt.ogg"), "Rocket Glider (© Fluidvolt)"],
	[preload("res://music/urbania.ogg"), "Urbania (CC-BY Dan Knoflicek)"],
	[preload("res://music/Viktor Kraus - Well oiled, shiny Oscillators.ogg"), "Well oiled, shiny Oscillators (CC-BY Viktor Kraus)"],
	[preload("res://music/Funked Up.ogg"), "Funked Up (CC0 Joth)"],
	[preload("res://music/jazzy-blues.ogg"), "Jazzy Blues (CC0 LushoGames)"],
	[preload("res://music/Funkorama.ogg"), "Funkorama (CC-BY Kevin MacLeod)"],
]
var current_song := 0


func _input(event):
	if event.is_action_pressed("ui_accept") and $Kart/StartCamera.current:
		$CamPivot/Camera.set_deferred("current", true)
		$HUD/Controls.hide()
		AudioServer.set_bus_effect_enabled(1, 0, true)
	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if $CamPivot/Camera.current:
			$Kart/FirstPersonCamera.current = true
		elif $Kart/FirstPersonCamera.current:
			$CamPivot/Camera.current = true


func _process(delta: float):
	$CamPivot.translation = lerp($CamPivot.translation, $Kart.translation, 15*delta)
	$CamPivot.rotation.y = lerp_angle($CamPivot.rotation.y, $Kart.rotation.y, 15*delta)
	if running:
		current_time += delta
		$HUD/BottomHud/Scores/Current.text = "T: " + nice_stringify(current_time) + " s"


func nice_stringify(number: float):
	return str(stepify(number, 0.01)+0.001).trim_suffix("1")


func _on_FinishLine_body_entered(_body):
	if can_finish:
		if running and current_time < best_time:
			best_time = current_time
			$HUD/BottomHud/Scores/Best.text = "Best time: " + nice_stringify(best_time) + " s"
			$FinishLine/Explosion.play()
			Engine.time_scale = 0.1
			yield(get_tree().create_timer(0.1), "timeout")
			Engine.time_scale = 1
		else:
			$FinishLine/EndTurn.play()
		current_time = 0.0
		running = false
		can_finish = false
		emit_signal("finished")


func _on_FinishLine_body_exited(_body):
	running = true
	for n in get_tree().get_nodes_in_group("turn_local"):
		n.turn()


func _on_Midway_body_entered(_body):
	can_finish = true


func _on_LightOnOff_toggled(button_pressed):
	$SunLight.visible = button_pressed


func _on_AudioOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(2, not button_pressed)


func _on_Music_pressed() -> void:
	current_song += 1
	if current_song >= len(playlist):
		current_song = 0
	$Music.stop()
	$Music.stream = playlist[current_song][0]
	$HUD/TopHud/Rows/Label.text = playlist[current_song][1]
	$Music.play()
