extends Spatial

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

func _ready():
	var tod: OptionButton = $HUD/TopHud/Rows/TimeOfDay
	tod.add_item("sunset", 0)
	tod.add_item("dusk", 1)
	tod.add_item("night", 2)
	tod.add_item("day", 3)
	_on_TimeOfDay_item_selected(0)

func _input(event):
	if event.is_action_pressed("ui_accept") and $Kart/StartCamera.current:
		$Camera.set_deferred("current", true)
		$HUD/TopHud/Rows/Label.text = "Move: arrow keys / left stick"
		$HUD/BottomHud/Scores/Current.text = ""
		$HUD/BottomHud/Scores/Best.text = ""
		$HUD/TopHud/Disappear.play("disappear")
		AudioServer.set_bus_effect_enabled(1, 0, true)
	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if $Camera.current:
			$Kart/FirstPersonCamera.current = true
		elif $Kart/FirstPersonCamera.current:
			$Camera.current = true

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
		emit_signal("finished")

func _on_FinishLine_body_exited(_body):
	running = true

func _on_Midway_body_entered(_body):
	can_finish = true
	if not $Crowd.playing:
		$Crowd.play()


func _on_MusicOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(1, not button_pressed)


func _on_LightOnOff_toggled(button_pressed):
	$Lights.visible = button_pressed


func _on_AudioOnOff_toggled(button_pressed):
	AudioServer.set_bus_mute(2, not button_pressed)

func _on_TimeOfDay_item_selected(index):
	var cameras := [$Kart/StartCamera, $Kart/FirstPersonCamera, $Camera]
	for c in cameras:
		c.cull_mask &= ~30
		c.cull_mask |= int(pow(2, index+1))
		if index == 0:
			c.environment = preload("res://world/environments/env_sunset.tres")
		if index == 1:
			c.environment = preload("res://world/environments/env_dusk.tres")
		if index == 2:
			c.environment = preload("res://world/environments/env_night.tres")
		if index == 3:
			c.environment = preload("res://world/environments/env_day.tres")
	$Lights/SunLight.hide()
	$Lights/DayLight.hide()
	match index:
		0: # sunset
			$Lights/SunLight.show()
		3: # day
			$Lights/DayLight.show()
