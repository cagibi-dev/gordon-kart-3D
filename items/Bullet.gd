extends RigidBody

signal dead


func _on_LifeTime_timeout():
	destroy()


func _on_body_entered(_body):
	emit_signal("dead", translation)
	destroy()


func destroy():
	$MeshInstance.hide()
	$CPUParticles.emitting = false
	collision_layer = 0
	collision_mask = 0
	yield(get_tree().create_timer(1.0), "timeout")
	queue_free()
