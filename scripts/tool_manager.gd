extends Node

## Quản lý công cụ đang chọn trong toolbar.
## Chỉ hỗ trợ các tool cần cho Feature 01: NONE, HOE, SEED.

const TOOL_NONE := 0
const TOOL_HOE := 1
const TOOL_SEED := 2

enum Tool {
	NONE = TOOL_NONE,
	HOE = TOOL_HOE,
	SEED = TOOL_SEED,
}

signal tool_changed(tool: int)

var _selected_tool: int = TOOL_NONE

var selected_tool: int:
	get:
		return _selected_tool
	set(value):
		if _selected_tool == value:
			return
		_selected_tool = value
		tool_changed.emit(_selected_tool)


func _ready() -> void:
	_selected_tool = TOOL_NONE


func set_tool(tool: int) -> void:
	selected_tool = tool


func is_selected(tool: int) -> bool:
	return selected_tool == tool
