class_name RandomHelper

static func get_random_string_in_array(options: Array) -> String:
	var random = RandomNumberGenerator.new()
	return options[random.randi_range(0, options.size())]

static func get_random_enum(options: Dictionary) -> int:
	var random = RandomNumberGenerator.new()
	var keys = options.keys()
	var random_index = random.randi_range(0, keys.size())
	return options[keys[random_index]]

static func get_random_int_in_range(min: int, max: int):
	var random = RandomNumberGenerator.new()
	return random.randi_range(min, max)

static func get_random_float_in_range(min: float, max: float):
	var random = RandomNumberGenerator.new()
	return random.randf_range(min, max)
