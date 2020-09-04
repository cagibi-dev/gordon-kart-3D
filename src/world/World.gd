extends WorldEnvironment

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

func _input(event):
	if event.is_action_pressed("ui_accept") and $Kart/StartCamera.current:
		$Camera.set_deferred("current", true)
		$HUD/TopHud/Rows/Label.text = "Move: arrow keys / left stick"
		$HUD/BottomHud/Scores/Current.text = ""
		$HUD/BottomHud/Scores/Best.text = ""
		$HUD/TopHud/Disappear.play("disappear")
		AudioServer.set_bus_effect_enabled(1, 0, true)

func _process(delta: float):
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
		else:
			$FinishLine/EndTurn.play()
		current_time = 0.0
		running = false
		can_finish = false

func _on_FinishLine_body_exited(_body):
	running = true

func _on_Midway_body_entered(_body):
	can_finish = true


func _on_MusicOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(1, not button_pressed)


func _on_CrowdOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(3, not button_pressed)


func _on_LightOnOff_toggled(button_pressed):
	$Lights.visible = button_pressed


func _on_AudioOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(2, not button_pressed)


func _on_Portal_body_entered(_body):
	var err
	if get_tree().current_scene.filename != "res://world/NightWorld.tscn":
		err = get_tree().change_scene("res://world/NightWorld.tscn")
	else:
		err = get_tree().change_scene("res://world/World.tscn")
	assert(err == OK)
