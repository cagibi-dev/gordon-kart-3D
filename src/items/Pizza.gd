extends Area


func _on_body_entered(body):
	if body.has_method("boost"):
		body.boost()
	$CollisionShape.disabled = true
	visible = false
	$Sound.play()

func _on_finished():
	$CollisionShape.disabled = false
	visible = true
