extends Node2D

## Scene gốc của game — nối các phần của game lại với nhau.
##
## Phase 2: lưới 9 ô đất, mỗi ô tự trồng cây, cây lớn theo thời gian và thu hoạch được.

@onready var plots: Node2D = $Farm/Plots
@onready var status_label: Label = $UI/Status
@onready var inventory_label: Label = $UI/Inventory

## Số cây đã thu hoạch được. Phase 3 sẽ thay bằng kho hàng thật.
var inventory: int = 0


func _ready() -> void:
	# Lắng nghe tín hiệu từ tất cả ô đất trong nông trại.
	# bind(plot) gắn thêm ô đất vào signal, để biết ô nào vừa đổi trạng thái.
	for child in plots.get_children():
		var plot := child as CropPlot
		plot.state_changed.connect(_on_plot_state_changed.bind(plot))
		plot.harvested.connect(_on_plot_harvested)

	_update_status(CropPlot.State.PLAIN)
	_update_inventory()


func _on_plot_state_changed(state: int, plot: CropPlot) -> void:
	_update_status(state, plot)


func _on_plot_harvested(_crop_id: int) -> void:
	inventory += 1
	_update_inventory()


func _update_status(state: int, plot: CropPlot = null) -> void:
	# Tên ô đất để người chơi biết đang thao tác lên ô nào.
	var where := "Ô đất" if plot == null else "Ô đất %s" % plot.name.trim_prefix("Plot_")
	match state:
		CropPlot.State.PLAIN:
			status_label.text = "%s: trống — bấm chuột trái để cày" % where
		CropPlot.State.TILLED:
			status_label.text = "%s: đã cày — bấm chuột trái để gieo hạt" % where
		CropPlot.State.SEED:
			status_label.text = "%s: vừa gieo hạt — đang nảy mầm…" % where
		CropPlot.State.SPROUT:
			status_label.text = "%s: cây đang nảy mầm…" % where
		CropPlot.State.GROWING:
			status_label.text = "%s: cây đang lớn…" % where
		CropPlot.State.MATURE:
			status_label.text = "%s: cây chín rồi — bấm chuột trái để thu hoạch" % where


func _update_inventory() -> void:
	inventory_label.text = "Đã thu hoạch: %d cà rốt" % inventory
