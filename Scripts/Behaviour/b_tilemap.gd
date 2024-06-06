extends TileMap

signal coordinates_spawn(coordinates_spawn)

var astar_grid = AStarGrid2D.new():
	get: 
		return astar_grid
var map_rect = Rect2i()
var tile_size: Vector2i = get_tileset().tile_size
var tilemap_size: Vector2i = get_used_rect().end - get_used_rect().position

@onready var path: TileMap = $path

func _ready():
	map_rect = Rect2i(Vector2i(), tilemap_size)
	astar_grid.region = map_rect
	astar_grid.cell_size = tile_size
	astar_grid.offset = tile_size * 0.5
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	# Recorremos cada capa en busca de celdas que no sean transitables y luego las seteamos como tal
	var cell_wall: Array[Vector2i] = []
	var cell_spawn: Array[Vector2i] = []
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coordinates: Vector2i = Vector2i(i, j)
			for h in self.get_layers_count(): # Recorre cada capa
				var tile_data = self.get_cell_tile_data(h, coordinates)
				if tile_data:
					if self.get_cell_source_id(h, coordinates) >= 0:
						if (tile_data.get_custom_data('wall') == true):
							astar_grid.set_point_solid(coordinates)
							cell_wall.append(coordinates)
						if (tile_data.get_custom_data('spawn') == true):
							cell_spawn.append(coordinates)
							astar_grid.set_point_solid(coordinates, false)
	cell_spawn = get_cells_between(cell_spawn[0], cell_spawn[1]) 
	for coor_wall in cell_wall:
		if cell_spawn.has(coor_wall):
			cell_spawn.erase(coor_wall)
		# self.set_cell(0,coor_wall,30) # Muestra los espacios intransitables
	emit_signal("coordinates_spawn", cell_spawn)

func is_point_walkable(local_position) -> bool:
	var map_position = local_to_map(local_position)
	if map_rect.has_point(map_position):
		return not astar_grid.is_point_solid(map_position)
	return false

func get_cells_between(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	var x1 = min(start.x, end.x)
	var y1 = min(start.y, end.y)
	var x2 = max(start.x, end.x)
	var y2 = max(start.y, end.y)

	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			coordinates.append(Vector2i(x, y))

	return coordinates

func get_id_path_without_wall(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
		return astar_grid.get_id_path(
			local_to_map(start),
			local_to_map(end)
		).slice(1)

func find_path(start: Vector2i, goal: Vector2i) -> void:
	path.clear()
	var start_cell = local_to_map(start)
	var end_cell = local_to_map(goal)
	
	if start_cell == end_cell or !astar_grid.is_in_boundsv(start_cell) or !astar_grid.is_in_boundsv(end_cell):
		return

	var id_path = astar_grid.get_id_path(start_cell, end_cell)
	for id in id_path:
		path.set_cell(0, id, 1, Vector2(0, 0))
