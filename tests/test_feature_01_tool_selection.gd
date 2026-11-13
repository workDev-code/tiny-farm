extends SceneTree

const PASS := "PASS"
const FAIL := "FAIL"

var failed := 0


func _initialize() -> void:
	var main := (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(main)
	await _frames(2)

	var tool_manager = main.get_node("ToolManager")
	var plots := main.get_node("Farm/Plots")
	var plot := plots.get_node("Plot_1") as Area2D
	var tile = plot.get_node("FarmTile")
	var player_input = main.get_node("PlayerInput")

	_check("tool mặc định = NONE", tool_manager.selected_tool == tool_manager.TOOL_NONE)
	_check("tile bắt đầu là PLAIN", tile != null and tile.soil_state == tile.SoilState.PLAIN)

	tool_manager.set_tool(tool_manager.TOOL_HOE)
	var click_success: bool = player_input.try_handle_position(plot.global_position)
	_check("TC01 Hoe + PLAIN => TILLED", click_success and tile.soil_state == tile.SoilState.TILLED)

	click_success = player_input.try_handle_position(plot.global_position)
	_check("TC02 Hoe + TILLED => không đổi", not click_success and tile.soil_state == tile.SoilState.TILLED)

	tool_manager.set_tool(tool_manager.TOOL_NONE)
	click_success = player_input.try_handle_position(plot.global_position)
	_check("TC03 NONE + PLAIN => không đổi", not click_success and tile.soil_state == tile.SoilState.TILLED)

	tool_manager.set_tool(tool_manager.TOOL_SEED)
	click_success = player_input.try_handle_position(plot.global_position)
	_check("TC04 SEED + PLAIN => không đổi", not click_success and tile.soil_state == tile.SoilState.TILLED)

	tool_manager.set_tool(tool_manager.TOOL_HOE)
	tile.soil_state = tile.SoilState.PLAIN
	tile._sync_sprite()
	var outside_click: bool = player_input.try_handle_position(Vector2(-200, -200))
	_check("TC05 click ngoài farm => không đổi", not outside_click and tile.soil_state == tile.SoilState.PLAIN)

	print("")
	if failed == 0:
		print("PASS — tất cả test Tool Selection + Hoe Interaction đạt.")
		quit(0)
	else:
		print("FAIL — %d test sai." % failed)
		quit(1)


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS  %s" % label)
	else:
		failed += 1
		print("  FAIL  %s" % label)


func _frames(count: int) -> void:
	for i in count:
		await process_frame
