extends Node2D

## Scene gốc của game — nối các phần của game lại với nhau.
##
## Phase 1: nền + một ô đất + một dòng thông báo phản hồi.

@onready var plot: CropPlot = $Farm/Plot
@onready var status_label: Label = $UI/Status


func _ready() -> void:
	# Lắng nghe tín hiệu từ ô đất. Khi ô đất đổi trạng thái, UI cập nhật theo.
	plot.state_changed.connect(_on_plot_state_changed)
	_update_status(plot.state)


func _on_plot_state_changed(state: int) -> void:
	_update_status(state)


func _update_status(state: int) -> void:
	match state:
		CropPlot.State.PLAIN:
			status_label.text = "Ô đất: trống — bấm chuột trái để cày"
		CropPlot.State.TILLED:
			status_label.text = "Ô đất: đã cày — bấm chuột trái để trả lại"
