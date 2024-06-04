class_name ManagerPufs
extends Node2D

@export var total_pufs: Array = []

# Variables para el sistema de selección de pufs
@onready var selected_pufs: Array = []

func _save_selected(selected: Node2D):
	selected_pufs.push_back(selected)

func _is_in_array_selected(selected: Node2D) -> bool:
	return selected_pufs.has(selected)

func _remove_selected(selected: Node2D):
	selected_pufs.erase(selected)

func _deselect_all():
	for selected in selected_pufs:
		_call_to_method(selected.get_child(0), DefinitionsHelper.DESELECT)

func _call_to_method(selected: Node3D, method: String):
	if selected.has_method(method):
		selected.call(method)

func _clean_selecteds():
	_deselect_all()
	selected_pufs.clear()
