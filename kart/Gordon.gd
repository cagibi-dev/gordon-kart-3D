extends Spatial


func hide_face():
	for n in [$Head/LeftEye, $Head/RightEye, $Head/EyeBrows, $Head/Nose, $Head/Head2/Mouth]:
		n.hide()
