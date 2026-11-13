extends Node

@export var tool_manager_path: NodePath = "../ToolManager"

var tool_manager: Node


func _ready() -> void:
	tool_manager = get_node_or_null(tool_manager_path)


func handle_click(plot: Node) -> bool:
	if plot == null:
		return false
	if tool_manager == null:
		return false

	var tile = plot.get_node_or_null("FarmTile")
	if tile == null:
		return false

	return tile.apply_tool(tool_manager.selected_tool)
