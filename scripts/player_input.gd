extends Node

@export var farm_path: NodePath = "../Farm/Plots"
@export var controller_path: NodePath = "../FarmingController"

var farm_root: Node
var controller: Node


func _ready() -> void:
	farm_root = get_node_or_null(farm_path)
	controller = get_node_or_null(controller_path)


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton):
		return
	var mouse_event := event as InputEventMouseButton
	if mouse_event.button_index != MOUSE_BUTTON_LEFT or not mouse_event.pressed:
		return
	try_handle_position(mouse_event.global_position)


func try_handle_position(world_position: Vector2) -> bool:
	if farm_root == null or controller == null:
		return false
	var plot := _find_plot_at(world_position)
	if plot == null:
		return false
	return controller.handle_click(plot)


func _find_plot_at(world_position: Vector2) -> Node:
	if farm_root == null:
		return null
	for child in farm_root.get_children():
		if not child is Area2D:
			continue
		var plot := child as Area2D
		var center := plot.global_position
		var half_size := Vector2(32.0, 32.0)
		if abs(world_position.x - center.x) <= half_size.x and abs(world_position.y - center.y) <= half_size.y:
			return plot
	return null
