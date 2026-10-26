class_name CropPlot
extends Area2D

## Một ô đất trong nông trại.
##
## Phase 1: ô đất có 2 trạng thái — trống và đã cày. Bấm chuột trái để đổi
## trạng thái. Mục đích của phase này là kiểm tra luồng: input -> signal -> đổi hình.

## Phát ra mỗi khi trạng thái ô đất thay đổi.
signal state_changed(state: int)

enum State {
	PLAIN,  ## Đất trống, chưa cày
	TILLED, ## Đã cày
}

## Hình ảnh khi ô đất trống.
@export var plain_texture: Texture2D
## Hình ảnh khi ô đất đã cày.
@export var tilled_texture: Texture2D

@onready var sprite: Sprite2D = $Sprite

var state: State = State.PLAIN


func _ready() -> void:
	# input_event chỉ phát ra khi Area2D có "input_pickable" bật (mặc định đã bật).
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_update_sprite()


## Đổi qua lại giữa 2 trạng thái.
func toggle_state() -> void:
	state = State.TILLED if state == State.PLAIN else State.PLAIN
	_update_sprite()
	state_changed.emit(state)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Chỉ quan tâm tới cú nhấn chuột trái.
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			toggle_state()


func _on_mouse_entered() -> void:
	# Sáng nhẹ ô đất khi rê chuột vào, để người chơi biết ô nào đang chọn.
	sprite.modulate = Color(1.25, 1.25, 1.25)


func _on_mouse_exited() -> void:
	sprite.modulate = Color.WHITE


func _update_sprite() -> void:
	match state:
		State.PLAIN:
			sprite.texture = plain_texture
		State.TILLED:
			sprite.texture = tilled_texture
