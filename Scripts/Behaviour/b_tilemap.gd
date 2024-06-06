extends TileMap

var astar_grid = AStarGrid2D.new()
var map_rect = Rect2i()
var tile_size: Vector2i = get_tileset().tile_size
var tilemap_size: Vector2i = get_used_rect().end - get_used_rect().position
var start_cell: Vector2i
var end_cell: Vector2i

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
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coordinates = Vector2i(i, j)
			for h in self.get_layers_count(): # Recorre cada capa
				var tile_data = get_cell_tile_data(h, coordinates)
				if tile_data:
					if self.get_cell_source_id(h, coordinates) >= 0:
						if (self.get_cell_tile_data(h, coordinates).get_custom_data('wall') == true):
							cell_wall.append(coordinates)
	for coor_wall in cell_wall:
		print(coor_wall)
		astar_grid.set_point_solid(coor_wall)
		# self.set_cell(0,coor_wall,30) Muestra los espacios intransitables

func is_point_walkable(local_position):
	var map_position = local_to_map(local_position)
	if map_rect.has_point(map_position):
		return not astar_grid.is_point_solid(map_position)
	return false


