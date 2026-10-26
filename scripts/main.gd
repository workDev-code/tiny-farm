extends Node2D

## Scene gốc của game — nối các phần của game lại với nhau.
##
## Main đóng vai trò điều phối: nhận tín hiệu từ ô đất, hỏi `GameManager` lấy hạt giống,
## rồi bảo ô đất trồng. Main không tự lưu tiền hay hạt giống.

@onready var ui: GameUI = $UI
@onready var plots: Node2D = $Farm/Plots


func _ready() -> void:
	# Lắng nghe tín hiệu từ tất cả ô đất trong nông trại.
	# bind(plot) gắn thêm ô đất vào signal, để biết ô nào vừa đổi trạng thái.
	for child in plots.get_children():
		var plot := child as CropPlot
		plot.state_changed.connect(_on_plot_state_changed.bind(plot))
		plot.plant_requested.connect(_on_plot_plant_requested)
		plot.harvested.connect(_on_plot_harvested)

	ui.set_status("Ô đất: trống — bấm chuột trái để cày")


func _on_plot_state_changed(state: int, plot: CropPlot) -> void:
	ui.set_status(_status_text(state, plot))


## Người chơi bấm vào ô đất đã cày: cần lấy 1 hạt giống đang chọn để trồng.
func _on_plot_plant_requested(plot: CropPlot) -> void:
	var crop := GameManager.take_selected_seed()
	if crop == null:
		# GameManager đã phát thông báo lý do lên UI.
		return

	plot.plant(crop, GameManager.growth_speed)
	ui.set_status("%s: vừa gieo hạt %s — đang nảy mầm…" % [_plot_label(plot), crop.display_name])


func _on_plot_harvested(crop_id: int) -> void:
	var crop := GameManager.get_crop(crop_id)
	GameManager.add_produce(crop_id)
	if crop != null:
		ui.set_status("Đã thu hoạch 1 %s — vào kho, nhớ bán đi" % crop.display_name)


func _status_text(state: int, plot: CropPlot) -> String:
	var where := _plot_label(plot)
	match state:
		CropPlot.State.PLAIN:
			return "%s: trống — bấm chuột trái để cày" % where
		CropPlot.State.TILLED:
			return "%s: đã cày — bấm chuột trái để gieo hạt" % where
		CropPlot.State.SEED:
			return "%s: vừa gieo hạt — đang nảy mầm…" % where
		CropPlot.State.SPROUT:
			return "%s: cây đang nảy mầm…" % where
		CropPlot.State.GROWING:
			return "%s: cây đang lớn…" % where
		CropPlot.State.MATURE:
			return "%s: cây chín rồi — bấm chuột trái để thu hoạch" % where
	return where


func _plot_label(plot: CropPlot) -> String:
	return "Ô đất %s" % plot.name.trim_prefix("Plot_")
