extends Spatial

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

onready var camera_start: Camera = $Kart/StartCamera
onready var camera_tps: Camera = $CamPivot/Camera
onready var camera_fps: Camera = $Kart/FirstPersonCamera
onready var sunset_light: DirectionalLight = $Lights/SunLight
onready var day_light: DirectionalLight = $Lights/DayLight
onready var cam_pivot: Spatial = $CamPivot
onready var kart_node: Spatial = $Kart
onready var current_time_node: Label = $HUD/Current


"""var playlist := [
	[null, "silence"],
	[preload("res://music/Buster_Prototype_Fluidvolt.ogg"), "Buster Prototype (© Fluidvolt)"],
	[preload("res://music/Rocket_Glider_Fluidvolt.ogg"), "Rocket Glider (© Fluidvolt)"],
	[preload("res://music/urbania.ogg"), "Urbania (CC-BY Dan Knoflicek)"],
	[preload("res://music/Viktor Kraus - Well oiled, shiny Oscillators.ogg"), "Well oiled, shiny Oscillators (CC-BY Viktor Kraus)"],
	[preload("res://music/Funked Up.ogg"), "Funked Up (CC0 Joth)"],
	[preload("res://music/jazzy-blues.ogg"), "Jazzy Blues (CC0 LushoGames)"],
	[preload("res://music/Funkorama.ogg"), "Funkorama (CC-BY Kevin MacLeod)"],
]
var current_song := 0"""

var daylist := [
	preload("res://world/environments/env_day.tres"),
	preload("res://world/environments/env_sunset.tres"),
]
var time_of_day := 0


func _ready():
	make_props_destructible()


func make_everything_unshaded(unshaded := true):
	$Lights.visible = not unshaded
	var mats := [
		preload("res://items/barrel/barrel.material"),
		preload("res://kart/car6_mat.material"),
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
	]
	for mat in mats:
		mat.set_flag(0, unshaded)


func make_props_destructible():
	var shape := BoxShape.new()
	shape.extents = Vector3(1, 2, 1)
	for cell in $GridMap.get_used_cells():
		var type: int = $GridMap.get_cell_item(cell.x, cell.y, cell.z)
		if type in [5, 6, 7, 8, 9, 15, 16, 17, 18, 19, 41, 43]:
			var area := Area.new()
			area.translation = $GridMap.map_to_world(cell.x, cell.y, cell.z)
			area.collision_layer = 0
			area.collision_mask = 2
			var shapenode := CollisionShape.new()
			shapenode.shape = shape
			add_child(area)
			area.add_child(shapenode)
			var err := area.connect("body_entered", self, "make_cell_explode", [ area, cell ])
			assert(err == OK)


func make_cell_explode(body: PhysicsBody, area: Area, cell: Vector3):
	area.queue_free()
	$Explode.reset_physics_interpolation()
	$Explode.translation = area.translation
	$Explode.play()
	$Explode/Visual.frame = 0
	$Explode/Visual.play("explode")
	if body and body.has_method("apply_central_impulse"):
		body.apply_central_impulse((area.global_transform.origin - body.global_transform.origin).normalized() * -2000)
	yield(get_tree(), "physics_frame")
	$GridMap.set_cell_item(cell.x, cell.y, cell.z, -1)


func _input(event):
	if not event.is_action_type():
		return

	if event.is_action_pressed("brake") and camera_start.current:
		# START THE GAME
		camera_tps.set_deferred("current", true)
		camera_start.get_node("Anim").queue_free()
		AudioServer.set_bus_effect_enabled(1, 0, true)
		$HUD/Start.hide()
	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if camera_tps.current:
			camera_fps.current = true
			$Gordon.hide()
		elif camera_fps.current:
			camera_tps.current = true
			$Gordon.show()

	if event.is_action_pressed("set_music"):
		next_music()
		make_everything_unshaded($Lights.visible)
	if event.is_action_pressed("set_env"):
		next_env()

	var acts := ["accelerate", "accelerate_backwards", "move_right", "move_left", "ui_focus_next", "brake", "reset", "set_music", "set_env"]
	var bs := $HUD/LiveControls.get_children()
	for i in range(len(bs)):
		bs[i].frame = 1 if Input.is_action_pressed(acts[i]) else 0


func _physics_process(delta: float):
	cam_pivot.translation = lerp(cam_pivot.translation, kart_node.translation, 15*delta)
	cam_pivot.rotation.y = lerp_angle(cam_pivot.rotation.y, kart_node.rotation.y, 15*delta)
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


func _on_FinishLine_body_exited(_body: CollisionObject):
	running = true
	for n in get_tree().get_nodes_in_group("turn_local"):
		n.restore()


func _on_Midway_body_entered(_body):
	can_finish = true


func next_music() -> void:
	$HUD/Label.text = "music not found"
	"""current_song += 1
	if current_song >= len(playlist):
		current_song = 0
	$Music.stop()
	$Music.stream = playlist[current_song][0]
	$HUD/Label.text = playlist[current_song][1]
	$Music.play()"""


func next_env() -> void:
	time_of_day += 1
	if time_of_day >= len(daylist):
		time_of_day = 0
	var hour := ""
	if time_of_day == 0:
		hour = "13:" + str(20 + randi() % 25)
	else:
		hour = "19:" + str(10 + randi() % 45)
	$HUD/Label.text = hour
	for cam in [camera_fps, camera_tps, camera_start]:
		cam.environment = daylist[time_of_day]
		cam.cull_mask &= ~30
		cam.cull_mask |= int(pow(2, time_of_day+1))

	sunset_light.hide()
	day_light.hide()
	match time_of_day:
		0: # sunset
			day_light.show()
		1: # day
			sunset_light.show()
