extends Spatial


func _process(delta: float):
	$Pivot.rotate_y(delta)
