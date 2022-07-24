extends Spatial


func toggle_face(new_visible: bool = false):
	for n in [$Head/LeftEye, $Head/RightEye, $Head/EyeBrows, $Head/Nose, $Head/Head2/Mouth]:
		n.visible = new_visible
