extends TileMap

var astar_grid = AStarGrid2D.new()
var map_rect = Rect2i()
var tile_size: Vector2i = get_tileset().tile_size
var tilemap_size: Vector2i = get_used_rect().end - get_used_rect().position

func _ready():
	map_rect = Rect2i(Vector2i(), tilemap_size)
	astar_grid.region = map_rect
	astar_grid.cell_size = tile_size
	astar_grid.offset = tile_size * 0.5
	astar_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	
	for i in tilemap_size.x:
		for j in tilemap_size.y:
			var coordinates = Vector2i(i, j)
			var tile_data = get_cell_tile_data(0, coordinates)
			if self.get_cell_source_id(0, coordinates) >= 0:
				var tile_type = self.get_cell_tile_data(0, coordinates).get_custom_data('wall')
				astar_grid.set_point_solid(Vector2i(i, j), tile_type)
			else:
				astar_grid.set_point_solid(Vector2i(i, j), true)

func is_point_walkable(local_position):
	var map_position = local_to_map(local_position)
	if map_rect.has_point(map_position):
		return not astar_grid.is_point_solid(map_position)
	return false
