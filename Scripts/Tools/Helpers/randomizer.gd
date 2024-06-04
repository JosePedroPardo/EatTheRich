class_name RandomHelper

static func get_random_string_in_array(options: Array) -> String:
	return options[randi() % options.size()]

static func get_random_enum(options: Dictionary) -> int:
	var keys = options.keys()
	var random_index = randi() % keys.size()
	return options[keys[random_index]]
