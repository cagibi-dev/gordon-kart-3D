extends Area


func _on_body_entered(_body):
	collision_mask = 0
	visible = 0
	$Sound.play()
