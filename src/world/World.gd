extends WorldEnvironment

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

func _input(event):
	if event.is_action_pressed("ui_accept") and $Kart/StartCamera.current:
		$Camera.set_deferred("current", true)
		$HUD/ColorRect/Label.text = "Touches fléchées : se déplacer"
		$HUD/Scores/Current.text = ""
		$HUD/Scores/Best.text = ""
		$HUD/ColorRect/Disappear.play("disappear")
		AudioServer.set_bus_effect_enabled(1, 0, true)

func _process(delta: float):
	if running:
		current_time += delta
		$HUD/Scores/Current.text = "T: " + str(stepify(current_time, 0.01)) + " s"

func _on_FinishLine_body_entered(_body):
	if can_finish:
		if running and current_time < best_time:
			best_time = current_time
			$HUD/Scores/Best.text = "Meilleur temps: " + str(stepify(best_time, 0.01)) + " s"
			$FinishLine/Explosion.play()
		else:
			$EndTurn.play()
		current_time = 0.0
		running = false
		can_finish = false

func _on_FinishLine_body_exited(_body):
	running = true

func _on_Midway_body_entered(_body):
	can_finish = true
