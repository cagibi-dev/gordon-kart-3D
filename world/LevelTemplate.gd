extends Spatial


onready var gridmap: GridMap = $GridMap

# orthogonal indexes:
# 10 = 180 deg Y
# 16/22 = 90 deg Y


func build_tower(offset: Vector3, radius := 2, height := 4):
	# one level at a time
	for y in range(offset.y, offset.y + 2 + height * 2, 2):
		var minx := offset.x - radius
		var maxx := offset.x + radius
		var minz := offset.z - radius
		var maxz := offset.z + radius
		var tile_id := 44 if y == offset.y else 54
		for x in [minx, maxx]:
			for z in range(minz, maxz + 1):
				gridmap.set_cell_item(x, y, z, tile_id, 22 if x == minx else 16)
		for z in [minz, maxz]:
			for x in range(minx + 1, maxx):
				gridmap.set_cell_item(x, y, z, tile_id, 10 if z == minz else 0)


func build_vertical_road(centerx, minz, maxz):
	for z in range(minz, maxz):
		gridmap.set_cell_item(centerx - 1, -1, z, 20, 16)
		gridmap.set_cell_item(centerx + 1, -1, z, 20, 22)
		gridmap.set_cell_item(centerx, -1, z, 15) # asphalt
		# gridmap.set_cell_item(x, -1, z, 14) # grass


func build_horizontal_road(centerz, minx, maxx):
	for x in range(minx, maxx):
		gridmap.set_cell_item(x, -1, centerz - 1, 20, 0)
		gridmap.set_cell_item(x, -1, centerz + 1, 20, 10)
		gridmap.set_cell_item(x, -1, centerz, 15) # asphalt


func _ready():
	for x in [-20, -12, -4, 4, 12, 20]:
		for z in [-20, -12, -4, 4, 12, 20]:
			build_tower(Vector3(x, 0, z), 2, 5)
	# procgen city
	for l in [-16, -8, 0, 8, 16]:
		build_vertical_road(l, -220, 220)
		build_horizontal_road(l, -220, 220)


func _physics_process(delta: float):
	$CamPivot.translation = lerp($CamPivot.translation, $Kart.translation, 15*delta)
	$CamPivot.rotation.y = lerp_angle($CamPivot.rotation.y, $Kart.rotation.y, 15*delta)

