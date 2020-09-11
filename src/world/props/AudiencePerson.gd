extends RigidBody


const body_colors = [
	preload("res://materials/DarkGreen.material"),
	preload("res://materials/Grey.material"),
	preload("res://materials/Green.material"),
	preload("res://materials/Red.material"),
]

const hair_colors = [
	preload("res://materials/Grey.material"),
	preload("res://materials/Red.material"),
	preload("res://materials/Yellow.material"),
]

func _ready():
	# random cloth color
	var body_mat = body_colors[randi() % body_colors.size()]
	$Body.set_surface_material(0, body_mat)
	if randi() % 2 > 0:
		$Head/Hair.show()
		var hair_mat = hair_colors[randi() % hair_colors.size()]
		if randi() % 2 > 0:
			$Head/Hair/Hair2.show()
			$Head/Hair/Hair2.set_surface_material(0, hair_mat)
		$Head/Hair.set_surface_material(0, hair_mat)

func _on_JumpTimer_timeout():
	apply_central_impulse(Vector3.UP * 4)
	$JumpTimer.wait_time = 1 + randf()
