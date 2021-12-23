extends Area


func _on_body_entered(body: Node) -> void:
	if body.has_method("refuel"):
		body.refuel(20)
		body.boost(-2)
	set_deferred("monitoring", false)
	hide()
	$Got.play()

func turn() -> void:
	show()
	monitoring = true
