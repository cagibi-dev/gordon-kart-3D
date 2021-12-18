extends Area


func _on_body_entered(body: Node) -> void:
	body.fuel += 20
	if body.fuel > 100:
		body.fuel = 100
	set_deferred("monitoring", false)
	hide()
	$Got.play()

func turn() -> void:
	show()
	monitoring = true
