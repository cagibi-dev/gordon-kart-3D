extends Area


func _on_body_entered(body: Node) -> void:
	if body.has_method("refuel"):
		body.boost(3)
		body.refuel(-1)
	set_deferred("monitoring", false)
	hide()
	$Got.play()

func turn() -> void:
	show()
	monitoring = true
