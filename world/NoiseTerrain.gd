extends StaticBody


export (Texture) var heightmap: Texture = preload("res://world/terrain_noise.tres")
export (Vector2) var chunk_size := Vector2(32, 32)


func _ready():
	var sea_level_offset: float = $Hills.translation.y
	yield(heightmap, "changed")
	var image := heightmap.get_data()
	image.lock()

	var map := PoolRealArray()
	var image_size := image.get_size() # assume square

	for y in range(chunk_size.y + 1):
		for x in range(chunk_size.x + 1):
			# warning-ignore:narrowing_conversion
			# warning-ignore:narrowing_conversion
			var pixel_value: float = image.get_pixel(
				min(x, chunk_size.x - 1) * (image_size.x / chunk_size.x),
				min(y, chunk_size.y - 1) * (image_size.y / chunk_size.y)).r
			var height := 32.0 * pixel_value + sea_level_offset

			# the sea is a flat road
			if height < -1:
				height = -1

			map.append(height)
	image.unlock()

	$CollisionShape.shape.map_data = map
