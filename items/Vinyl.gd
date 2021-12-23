extends Area


func _on_Vinyl_body_entered(_body: Node) -> void:
	get_tree().quit()
