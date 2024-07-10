tool
extends StaticBody


export (Texture) var heightmap: Texture setget set_heightmap
export (Vector2) var chunk_size := Vector2(32, 32) setget set_size


func set_heightmap(new_hm: Texture):
	heightmap = new_hm
	recreate_terrain()


func set_size(new_size: Vector2):
	chunk_size = new_size
	recreate_terrain()


func recreate_terrain():
	if not is_inside_tree():
		return
	var sea_level_offset: float = $Hills.translation.y
	#yield(heightmap, "changed")
	var image := heightmap.get_data()
	if image == null:
		return
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

	var mat: ShaderMaterial = $Hills.mesh.material
	mat.set_shader_param("heightmap", heightmap)
	mat = $Water.mesh.material
	mat.set_shader_param("heightmap", heightmap)
