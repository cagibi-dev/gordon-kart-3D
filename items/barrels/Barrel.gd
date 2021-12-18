extends Area


func _on_body_entered(body: Node) -> void:
	if visible:
		body.fuel += 5
		monitoring = false
		hide()
		$Got.play()

func turn() -> void:
	show()
	monitoring = true
