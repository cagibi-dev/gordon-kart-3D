extends Node


func _on_SfxSlider_value_changed(value):
	AudioServer.set_bus_volume_db(2, linear2db(value))
	$TestSound.play()


func _on_MusicSlider_value_changed(value):
	AudioServer.set_bus_volume_db(1, linear2db(value))
	$TestSound.play()
