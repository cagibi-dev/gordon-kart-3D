extends RigidBody


const colors = [
	preload("res://materials/DarkGreen.material"),
	preload("res://materials/Grey.material"),
	preload("res://materials/Green.material"),
	preload("res://materials/Red.material"),
	preload("res://materials/Yellow.material"),
]

func _ready():
	# random cloth color
	$Body.set_surface_material(0, colors[randi() % colors.size()])
	if randi() % 2 == 0:
		$Head/Hair.show()
		var hair_mat = colors[randi() % colors.size()]
		$Head/Hair.set_surface_material(0, hair_mat)
		$Head/Hair/Hair2.set_surface_material(0, hair_mat)

func _on_JumpTimer_timeout():
	apply_central_impulse(Vector3.UP * 4)
	$JumpTimer.wait_time = 1 + randf()
