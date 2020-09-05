extends Area


func _ready():
	get_tree().current_scene.connect("finished", self, "_on_finished")

func _on_body_entered(body):
	if body.has_method("boost"):
		body.boost()
	$CollisionShape.disabled = true
	visible = false
	$Sound.play()

func _on_finished():
	$CollisionShape.disabled = false
	visible = true
