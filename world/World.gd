extends Spatial

signal finished

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

# available cameras
onready var cams := [$CamPivot/Camera, $Kart/FirstPersonCamera, $Kart/StartCamera]

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

var daylist := [
	preload("res://world/environments/env_day.tres"),
	preload("res://world/environments/env_sunset.tres"),
]
var time_of_day := 0


func _ready():
	"""for _i in range(64):
		var crate := preload("res://items/barrel/Crate.tscn").instance()
		crate.translation = Vector3(rand_range(-60, 60), 12, rand_range(-60, 60))
		add_child(crate)
		var barrel := preload("res://items/barrel/Barrel.tscn").instance()
		barrel.translation = Vector3(rand_range(-60, 60), 12, rand_range(-60, 60))
		add_child(barrel)"""
	make_props_destructible()


func make_props_destructible():
	var shape := BoxShape.new()
	shape.extents = Vector3(1, 1, 1)
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
		body.apply_central_impulse((area.global_translation - body.global_translation).normalized() * -2000)
	yield(get_tree(), "physics_frame")
	$GridMap.set_cell_item(cell.x, cell.y, cell.z, -1)


func _input(event):
	if not event.is_action_type():
		return

	if event.is_action_pressed("brake") and $Kart/StartCamera.current:
		# START THE GAME
		$CamPivot/Camera.set_deferred("current", true)
		$Kart/StartCamera/Anim.queue_free()
		AudioServer.set_bus_effect_enabled(1, 0, true)
		$HUD/Start.hide()
		# we don't need his face anymore.
		$Kart/Gordon.hide_face()
	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if $CamPivot/Camera.current:
			$Kart/FirstPersonCamera.current = true
		elif $Kart/FirstPersonCamera.current:
			$CamPivot/Camera.current = true

	if event.is_action_pressed("set_sfx"):
		AudioServer.set_bus_mute(2, not AudioServer.is_bus_mute(2))
	if event.is_action_pressed("set_music"):
		next_music()
	if event.is_action_pressed("set_env"):
		next_env()

	var acts := ["accelerate", "accelerate_backwards", "move_right", "move_left", "ui_focus_next", "brake", "reset", "set_sfx", "set_music", "set_env"]
	var bs := $HUD/LiveControls.get_children()
	for i in range(len(bs)):
		bs[i].frame = 1 if Input.is_action_pressed(acts[i]) else 0


func _physics_process(delta: float):
	$CamPivot.translation = lerp($CamPivot.translation, $Kart.translation, 15*delta)
	$CamPivot.rotation.y = lerp_angle($CamPivot.rotation.y, $Kart.rotation.y, 15*delta)
	if running:
		current_time += delta
		$HUD/Scores/Current.text = "T: " + nice_stringify(current_time) + " s"


func nice_stringify(number: float):
	return str(stepify(number, 0.01)+0.001).trim_suffix("1")


func _on_FinishLine_body_entered(_body):
	if can_finish:
		if running and current_time < best_time:
			best_time = current_time
			$HUD/Scores/Best.text = "Best time: " + nice_stringify(best_time) + " s"
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
		n.turn()


func _on_Midway_body_entered(_body):
	can_finish = true


func next_music() -> void:
	current_song += 1
	if current_song >= len(playlist):
		current_song = 0
	$Music.stop()
	$Music.stream = playlist[current_song][0]
	$HUD/Label.text = playlist[current_song][1]
	$Music.play()


func next_env() -> void:
	if time_of_day == 3:
		if get_viewport().debug_draw == Viewport.DEBUG_DRAW_DISABLED:
			# bonus: low perf mode
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
			for a in get_tree().get_nodes_in_group("anim"):
				a.stop()
			$HUD/Label.text = "low perf mode"
			return
		else:
			get_viewport().debug_draw = Viewport.DEBUG_DRAW_DISABLED
			for a in get_tree().get_nodes_in_group("anim"):
				a.play("spin")
	time_of_day += 1
	if time_of_day >= len(daylist):
		time_of_day = 0
	$HUD/Label.text = ["time: afternoon", "time: golden hour"][time_of_day]
	for cam in cams:
		cam.environment = daylist[time_of_day]
		cam.cull_mask &= ~30
		cam.cull_mask |= int(pow(2, time_of_day+1))

	$Lights/SunLight.hide()
	$Lights/DayLight.hide()
	match time_of_day:
		0: # sunset
			$Lights/DayLight.show()
		1: # day
			$Lights/SunLight.show()
