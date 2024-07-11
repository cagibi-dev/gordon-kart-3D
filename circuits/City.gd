extends "res://circuits/Circuit.gd"

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

onready var sunset_light: DirectionalLight = $Lights/SunLight
onready var day_light: DirectionalLight = $Lights/DayLight
onready var current_time_node: Label = $HUD/Current


func _ready():
	grid_map = $OldGridMap
	explodable_tiles = [5, 6, 7, 8, 9, 15, 16, 17, 18, 19, 41, 43]
	make_props_destructible() # rerun this bc gridmap changed


func _physics_process(delta: float):
	if running:
		current_time += delta
		current_time_node.text = "T: " + nice_stringify(current_time) + " s"


func nice_stringify(number: float) -> String:
	return str(stepify(number, 0.01)+0.001).trim_suffix("1")


func _on_FinishLine_body_entered(_body):
	if can_finish:
		if running and current_time < best_time:
			best_time = current_time
			$HUD/Best.text = "Best time: " + nice_stringify(best_time) + " s"
			$FinishLine/NewHighscore.play()
			Engine.time_scale = 0.1
			yield(get_tree().create_timer(0.1), "timeout")
			Engine.time_scale = 1
		$FinishLine/EndTurn.play()
		current_time = 0.0
		running = false
		can_finish = false
		emit_signal("finished")


func _on_FinishLine_body_exited(_body):
	running = true
	for n in get_tree().get_nodes_in_group("turn_local"):
		n.restore()


func _on_Midway_body_entered(_body):
	can_finish = true
