extends Node2D

## Scene gốc của game — nối các phần của game lại với nhau.
##
## Phase 2: ô đất tự trồng cây, cây lớn theo thời gian và thu hoạch được.

@onready var plot: CropPlot = $Farm/Plot
@onready var status_label: Label = $UI/Status
@onready var inventory_label: Label = $UI/Inventory

## Số cây đã thu hoạch được. Phase 3 sẽ thay bằng kho hàng thật.
var inventory: int = 0


func _ready() -> void:
	# Lắng nghe tín hiệu từ ô đất. Khi ô đất đổi trạng thái, UI cập nhật theo.
	plot.state_changed.connect(_on_plot_state_changed)
	plot.harvested.connect(_on_plot_harvested)
	_update_status(plot.state)
	_update_inventory()


func _on_plot_state_changed(state: int) -> void:
	_update_status(state)


func _on_plot_harvested(_crop_id: int) -> void:
	inventory += 1
	_update_inventory()


func _update_status(state: int) -> void:
	match state:
		CropPlot.State.PLAIN:
			status_label.text = "Ô đất: trống — bấm chuột trái để cày"
		CropPlot.State.TILLED:
			status_label.text = "Ô đất: đã cày — bấm chuột trái để gieo hạt"
		CropPlot.State.SEED:
			status_label.text = "Ô đất: vừa gieo hạt — đang nảy mầm…"
		CropPlot.State.SPROUT:
			status_label.text = "Ô đất: cây đang nảy mầm…"
		CropPlot.State.GROWING:
			status_label.text = "Ô đất: cây đang lớn…"
		CropPlot.State.MATURE:
			status_label.text = "Ô đất: cây chín rồi — bấm chuột trái để thu hoạch"


func _update_inventory() -> void:
	inventory_label.text = "Đã thu hoạch: %d cà rốt" % inventory
