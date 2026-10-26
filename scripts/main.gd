extends Node2D

## Scene gốc của game — nối các phần của game lại với nhau.
##
## Main đóng vai trò điều phối: nhận tín hiệu từ ô đất, hỏi `GameManager` lấy hạt giống,
## rồi bảo ô đất trồng. Main không tự lưu tiền hay hạt giống.

## Bao lâu giữa 2 lần vẽ lại dòng thông báo (giây).
const STATUS_REFRESH := 0.25

@onready var ui: GameUI = $UI
@onready var plots: Node2D = $Farm/Plots

## Ô đất vừa được thao tác — dùng để hiển thị đồng hồ đếm ngược.
var _last_plot: CropPlot = null
var _refresh_timer := 0.0


func _ready() -> void:
	# Lắng nghe tín hiệu từ tất cả ô đất trong nông trại.
	# bind(plot) gắn thêm ô đất vào signal, để biết ô nào vừa đổi trạng thái.
	for child in plots.get_children():
		var plot := child as CropPlot
		plot.state_changed.connect(_on_plot_state_changed.bind(plot))
		plot.plant_requested.connect(_on_plot_plant_requested)
		plot.harvested.connect(_on_plot_harvested)

	ui.set_status("Ô đất: trống — bấm chuột trái để cày")


func _process(delta: float) -> void:
	# Làm mới dòng thông báo để đồng hồ đếm ngược chạy.
	if _last_plot == null:
		return
	_refresh_timer += delta
	if _refresh_timer < STATUS_REFRESH:
		return
	_refresh_timer = 0.0
	ui.set_status(_status_text(_last_plot.state, _last_plot))


func _on_plot_state_changed(state: int, plot: CropPlot) -> void:
	_last_plot = plot
	ui.set_status(_status_text(state, plot))


## Người chơi bấm vào ô đất đã cày: cần lấy 1 hạt giống đang chọn để trồng.
func _on_plot_plant_requested(plot: CropPlot) -> void:
	var crop := GameManager.take_selected_seed()
	if crop == null:
		# Không đủ hạt giống — hiện lý do ngay trên dòng trạng thái.
		ui.set_status(_status_text(plot.state, plot))
		return

	plot.plant(crop, GameManager.growth_speed)
	ui.set_status(_status_text(plot.state, plot))


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
			return "%s: %s" % [where, _plant_hint()]
		CropPlot.State.SEED:
			return "%s: vừa gieo hạt %s (còn %.0fs)" % [where, _crop_name(plot), plot.time_to_mature()]
		CropPlot.State.SPROUT:
			return "%s: cây đang nảy mầm (còn %.0fs)" % [where, plot.time_to_mature()]
		CropPlot.State.GROWING:
			return "%s: cây đang lớn (còn %.0fs)" % [where, plot.time_to_mature()]
		CropPlot.State.MATURE:
			return "%s: cây chín rồi — bấm chuột trái để thu hoạch" % where
	return where


## Gợi ý cho người chơi biết sẽ gieo hạt gì và còn bao nhiêu hạt.
func _plant_hint() -> String:
	var crop := GameManager.get_crop(GameManager.selected_crop_id)
	if crop == null:
		return "đã cày — hãy chọn loại hạt giống ở thanh dưới màn hình"
	var count: int = GameManager.seeds[GameManager.selected_crop_id]
	if count <= 0:
		return "đã cày — chưa có hạt %s, hãy mua ở thanh dưới màn hình" % crop.display_name
	return "đã cày — bấm chuột trái để gieo hạt %s (còn %d hạt)" % [crop.display_name, count]


func _crop_name(plot: CropPlot) -> String:
	return plot.crop.display_name if plot.crop != null else ""


func _plot_label(plot: CropPlot) -> String:
	return "Ô đất %s" % plot.name.trim_prefix("Plot_")
