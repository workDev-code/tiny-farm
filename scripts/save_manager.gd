extends Node

## Quản lý lưu và tải dữ liệu game.
##
## Autoload, nên gọi được `SaveManager.save_game(...)` từ mọi nơi.

const SAVE_PATH := "user://save.json"
const SAVE_VERSION := 1


## Lưu trạng thái game hiện tại xuống đĩa.
func save_game(game_manager: Node, plots: Node) -> bool:
	var data := {
		"version": SAVE_VERSION,
		"saved_at": Time.get_unix_time_from_system(),
		"game_manager": game_manager.get_save_data(),
		"plots": [],
	}
	for plot in plots.get_children():
		data["plots"].append(plot.get_save_data())

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("SaveManager: không mở được file để ghi (%s)" % SAVE_PATH)
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true


## Tải trạng thái game từ đĩa. Trả về true nếu tải thành công.
func load_game(game_manager: Node, plots: Node) -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_warning("SaveManager: không mở được file để đọc (%s)" % SAVE_PATH)
		return false
	var text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var err := json.parse(text)
	if err != OK:
		# File hỏng (ghi dở, mất điện, crash): đổi tên để không ghi đè,
		# bắt đầu game mới. Người chơi không mất save cũ, có thể khôi phục thủ công.
		var backup_path := SAVE_PATH + ".corrupted"
		DirAccess.rename_absolute(SAVE_PATH, backup_path)
		push_warning("SaveManager: file save hỏng, đã đổi tên thành %s" % backup_path)
		return false

	var data: Variant = json.data
	if not (data is Dictionary):
		push_warning("SaveManager: dữ liệu save không phải Dictionary")
		return false

	var dict: Dictionary = data
	if int(dict.get("version", 0)) != SAVE_VERSION:
		push_warning("SaveManager: phiên bản save (%s) khác phiên bản hiện tại (%d)" % [dict.get("version", "?"), SAVE_VERSION])
		return false

	game_manager.load_from_save(dict.get("game_manager", {}))

	var plots_data: Variant = dict.get("plots", [])
	var plot_nodes := plots.get_children()
	for i in plot_nodes.size():
		if plots_data is Array and i < plots_data.size():
			plot_nodes[i].load_from_save(plots_data[i], game_manager.crops)
		else:
			plot_nodes[i].load_from_save({}, game_manager.crops)

	return true


## Xoá file save (dùng cho "chơi lại").
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
