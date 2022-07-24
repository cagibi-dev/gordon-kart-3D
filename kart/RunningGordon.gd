extends RigidBody


func _physics_process(delta: float):
	var in_run := Input.get_axis("ui_down", "ui_up")
	$Anim.playback_speed = 2 * in_run
	apply_central_impulse(-1000 * in_run * transform.basis.z * delta)
	add_torque(100 * Input.get_axis("ui_left", "ui_right") * Vector3.DOWN)


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("brake"):
		apply_central_impulse(1000 * Vector3.UP)
