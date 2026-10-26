class_name CropPlot
extends Area2D

## Một ô đất trong nông trại.
##
## Ô đất biết cày, gieo hạt, cây lớn dần theo thời gian và thu hoạch.
## Loại cây trồng và thời gian lớn lấy từ `CropData`.

## Trạng thái của một ô đất.
enum State {
	PLAIN,   ## Đất trống, chưa cày
	TILLED,  ## Đã cày, chờ gieo hạt
	SEED,    ## Vừa gieo hạt
	SPROUT,  ## Đã nảy mầm
	GROWING, ## Đang lớn
	MATURE,  ## Đã chín, sẵn sàng thu hoạch
}

## Ánh xạ trạng thái -> vị trí trong danh sách texture của cây.
const STAGE_INDEX := {
	State.SEED: 0,
	State.SPROUT: 1,
	State.GROWING: 2,
	State.MATURE: 3,
}

## Phát ra mỗi khi trạng thái ô đất thay đổi.
signal state_changed(state: State)

## Phát ra khi người chơi bấm vào ô đất đã cày, cần gieo hạt.
signal plant_requested(plot: CropPlot)

## Phát ra khi người chơi thu hoạch được một cây.
signal harvested(crop_id: int)

## Hình ảnh khi ô đất trống.
@export var plain_texture: Texture2D
## Hình ảnh khi ô đất đã cày.
@export var tilled_texture: Texture2D

@onready var soil_sprite: Sprite2D = $Soil
@onready var crop_sprite: Sprite2D = $Crop
@onready var grow_timer: Timer = $GrowTimer

## Loại cây đang trồng. Null khi ô đất trống.
var crop: CropData = null
var state: State = State.PLAIN


func _ready() -> void:
	# input_event chỉ phát ra khi Area2D có "input_pickable" bật (mặc định đã bật).
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	grow_timer.timeout.connect(_on_timer_timeout)

	_update_sprite()


## Trồng một loại cây lên ô đất.
## `speed` là hệ số tốc độ mọc (>1 = nhanh hơn).
func plant(new_crop: CropData, speed: float = 1.0) -> void:
	crop = new_crop
	grow_timer.wait_time = crop.time_per_stage() / maxf(speed, 0.01)
	_set_state(State.SEED)
	grow_timer.start()


## Xử lý khi người chơi bấm vào ô đất. Việc làm phụ thuộc vào trạng thái hiện tại.
func interact() -> void:
	match state:
		State.PLAIN:
			_set_state(State.TILLED)
		State.TILLED:
			# Ô đất đã cày: cần hạt giống. main.gd sẽ xử lý.
			plant_requested.emit(self)
		State.MATURE:
			_harvest()
		_:
			pass # Đang lớn thì chưa làm được gì.


## Thu hoạch cây đã chín.
func _harvest() -> void:
	if crop != null:
		harvested.emit(crop.id)
	crop = null
	_set_state(State.PLAIN)


## Cổng DUY NHẤT để đổi trạng thái ô đất.
## Mọi thay đổi trạng thái đều đi qua đây, nên không bao giờ quên đổi hình hay phát signal.
func _set_state(new_state: State) -> void:
	state = new_state
	_update_sprite()
	state_changed.emit(state)


## Cây lớn thêm một giai đoạn mỗi lần Timer hết giờ.
func _on_timer_timeout() -> void:
	match state:
		State.SEED:
			_set_state(State.SPROUT)
		State.SPROUT:
			_set_state(State.GROWING)
		State.GROWING:
			_set_state(State.MATURE)
			grow_timer.stop()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Chỉ quan tâm tới cú nhấn chuột trái.
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			interact()


func _on_mouse_entered() -> void:
	# Sáng nhẹ ô đất khi rê chuột vào, để người chơi biết ô nào đang chọn.
	# modulate trên node gốc sẽ áp dụng cho cả Soil lẫn Crop.
	modulate = Color(1.25, 1.25, 1.25)


func _on_mouse_exited() -> void:
	modulate = Color.WHITE


func _update_sprite() -> void:
	# Nền đất: trống thì lộ cỏ, đã cày thì hiện đất tilled (giữ nguyên tới khi thu hoạch).
	soil_sprite.texture = plain_texture if state == State.PLAIN else tilled_texture

	# Cây: chỉ hiện từ lúc gieo hạt, đè lên nền đất.
	if crop == null or not STAGE_INDEX.has(state):
		crop_sprite.texture = null
		return
	crop_sprite.texture = crop.stage_textures[STAGE_INDEX[state]]
