extends Node
class_name Circuit

var target_rotation := 0.0

export (String) var circuit_name := "nowhere"

onready var cameras := [
	$CamPivot/Camera,
	$Kart/FirstPersonCamera,
	$CamPivot/TopCam,
]
var current_cam := 0
var explodable_tiles := [0, 1, 2, 3, 9, 10, 11, 12, 13, 33, 35]
onready var cam_pivot: Spatial = $CamPivot
onready var kart_node: Spatial = $Kart
onready var grid_map: GridMap = $GridMap


func _ready():
	make_props_destructible()
	Globals.push_msg("You entered " + circuit_name)
	cam_pivot.position = kart_node.position
	setup_env(Globals.current_env)


func setup_env(env_id: int):
	var sunset_light: DirectionalLight = $SunLight
	var day_light: DirectionalLight = $DayLight

	for cam in cameras:
		cam.cull_mask &= ~30
		cam.cull_mask |= int(pow(2, env_id + 1))
	sunset_light.hide()
	day_light.hide()
	match env_id:
		0: # sunset
			sunset_light.show()
		2: # day
			day_light.show()


func make_props_destructible():
	print(grid_map)
	var shape := BoxShape.new()
	shape.extents = Vector3(1, 2, 1)
	for cell in grid_map.get_used_cells():
		var type: int = grid_map.get_cell_item(cell.x, cell.y, cell.z)
		if type in explodable_tiles:
			var area := Area.new()
			area.translation = grid_map.map_to_world(cell.x, cell.y, cell.z)
			area.collision_layer = 0
			area.collision_mask = 10
			var shapenode := CollisionShape.new()
			shapenode.shape = shape
			add_child(area)
			area.add_child(shapenode)
			var err := area.connect("body_entered", self, "make_cell_explode", [ area, cell ])
			assert(err == OK)


func make_cell_explode(body: PhysicsBody, area: Area, cell: Vector3):
	area.queue_free()
	create_explosion(area.translation)
	if body and body.has_method("apply_central_impulse"):
		body.apply_central_impulse((area.global_transform.origin - body.global_transform.origin).normalized() * -2000)
	yield(get_tree(), "physics_frame")
	grid_map.set_cell_item(int(cell.x), int(cell.y), int(cell.z), -1)


func create_explosion(pos: Vector3):
	$Explode.reset_physics_interpolation()
	$Explode.translation = pos
	$Explode.play()
	$Explode/Visual.frame = 0
	$Explode/Visual.play("explode")
	shake_screen()



func _input(event):
	if event.is_action_pressed("ui_focus_next"):
		next_cam()


func next_cam():
	current_cam = (current_cam + 1) % len(cameras)
	for i in range(len(cameras)):
		cameras[i].current = (i == current_cam)
	$Gordon.visible = (current_cam != 1)


func _physics_process(delta: float):
	#if kart_node.linear_velocity.length_squared() > 4.0:
	#	target_rotation = kart_node.linear_velocity.signed_angle_to(Vector3.BACK, Vector3.DOWN)
	target_rotation = kart_node.rotation.y

	cam_pivot.translation = lerp(cam_pivot.translation, kart_node.translation, 15*delta)
	cam_pivot.rotation.y = lerp_angle(cam_pivot.rotation.y, target_rotation, 15*delta)


func _on_Kart_shoot():
	var bullet := preload("res://items/Bullet.tscn").instance()
	bullet.transform = $Kart/Visor.global_transform
	var impulse: Vector3 = bullet.transform.basis * Vector3(0, 100, 1000)
	$Shoot.play()
	bullet.apply_central_impulse(impulse)
	$Kart.apply_central_impulse(-impulse)
	add_child(bullet)
	var err := bullet.connect("dead", self, "on_bullet_dead")
	assert(err == OK)

	shake_screen()


func shake_screen():
	var cam := get_viewport().get_camera()
	cam.h_offset = 0.2
	yield(get_tree().create_timer(0.05), "timeout")
	cam.h_offset = -0.2
	yield(get_tree().create_timer(0.05), "timeout")
	cam.h_offset = 0.1
	yield(get_tree().create_timer(0.05), "timeout")
	cam.h_offset = -0.1
	yield(get_tree().create_timer(0.05), "timeout")
	cam.h_offset = 0


func on_bullet_dead(pos: Vector3):
	create_explosion(pos)
