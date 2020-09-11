extends RigidBody


func _on_JumpTimer_timeout():
	apply_central_impulse(Vector3.UP * 4)
	$JumpTimer.wait_time = 1 + randf()
