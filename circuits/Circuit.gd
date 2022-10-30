extends Node

var best_time := 999999.0
var current_time := 0.0
var running := false
var can_finish := false

onready var camera_tps: Camera = $CamPivot/Camera
onready var camera_fps: Camera = $Kart/FirstPersonCamera
onready var cam_pivot: Spatial = $CamPivot
onready var kart_node: Spatial = $Kart


func _ready():
	make_props_destructible()


func make_everything_unshaded(unshaded := true):
	$SunLight.visible = not unshaded
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
	]
	for mat in mats:
		mat.set_flag(0, unshaded)


func make_props_destructible():
	var shape := BoxShape.new()
	shape.extents = Vector3(1, 2, 1)
	for cell in $GridMap.get_used_cells():
		var type: int = $GridMap.get_cell_item(cell.x, cell.y, cell.z)
		if type in [0, 1, 2, 3, 9, 10, 11, 12, 13, 33, 35]:
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

	if event.is_action_pressed("ui_focus_next") or event.is_action_pressed("ui_focus_prev"):
		if camera_tps.current:
			camera_fps.current = true
			$Gordon.hide()
		elif camera_fps.current:
			camera_tps.current = true
			$Gordon.show()

	if event.is_action_pressed("set_music"):
		make_everything_unshaded($Lights.visible)


func _physics_process(delta: float):
	cam_pivot.translation = lerp(cam_pivot.translation, kart_node.translation, 15*delta)
	cam_pivot.rotation.y = lerp_angle(cam_pivot.rotation.y, kart_node.rotation.y, 15*delta)
