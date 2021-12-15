extends Spatial

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false


func _input(event):
	if event.is_action_pressed("ui_accept") and $Kart/StartCamera.current:
		$CamPivot/Camera.set_deferred("current", true)
		$HUD/TopHud/Rows/Label.text = "Move: arrow keys / left stick"
		$HUD/BottomHud/Scores/Current.text = ""
		$HUD/BottomHud/Scores/Best.text = ""
		$HUD/TopHud/Disappear.play("disappear")
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


func _on_Midway_body_entered(_body):
	can_finish = true


func _on_MusicOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(1, not button_pressed)


func _on_LightOnOff_toggled(button_pressed):
	$SunLight.visible = button_pressed


func _on_AudioOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(2, not button_pressed)
