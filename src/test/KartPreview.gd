extends Spatial


func _process(delta: float):
	$Kart.rotate_y(delta)
