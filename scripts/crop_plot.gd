class_name CropPlot
extends Area2D

## Một ô đất trong nông trại.
##
## Phase 2: ô đất biết cày, gieo hạt, cây lớn dần theo thời gian và thu hoạch.

## Trạng thái của một ô đất.
enum State {
	PLAIN,   ## Đất trống, chưa cày
	TILLED,  ## Đã cày, chờ gieo hạt
	SEED,    ## Vừa gieo hạt
	SPROUT,  ## Đã nảy mầm
	GROWING, ## Đang lớn
	MATURE,  ## Đã chín, sẵn sàng thu hoạch
}

## Ánh xạ trạng thái -> vị trí trong stage_textures.
const STAGE_INDEX := {
	State.SEED: 0,
	State.SPROUT: 1,
	State.GROWING: 2,
	State.MATURE: 3,
}

## Loại cây trồng. Phase 2 mới chỉ có cà rốt.
enum Crop {
	CARROT,
}

## Phát ra mỗi khi trạng thái ô đất thay đổi.
signal state_changed(state: State)

## Phát ra khi người chơi thu hoạch được một cây.
signal harvested(crop_id: Crop)

## Hình ảnh khi ô đất trống.
@export var plain_texture: Texture2D
## Hình ảnh khi ô đất đã cày.
@export var tilled_texture: Texture2D
## Hình ảnh từng giai đoạn cây: [mầm, nảy mầm, lớn, chín].
@export var stage_textures: Array[Texture2D] = []
## Thời gian mỗi giai đoạn cây trồng (giây).
@export var grow_time_per_stage: float = 2.0

@onready var soil_sprite: Sprite2D = $Soil
@onready var crop_sprite: Sprite2D = $Crop
@onready var grow_timer: Timer = $GrowTimer

## Loại cây đang trồng trong ô này.
var crop_id: Crop = Crop.CARROT
var state: State = State.PLAIN


func _ready() -> void:
	# input_event chỉ phát ra khi Area2D có "input_pickable" bật (mặc định đã bật).
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	grow_timer.timeout.connect(_on_timer_timeout)

	# Thời gian mỗi giai đoạn lấy từ biến export, không cần sửa trong Inspector.
	grow_timer.wait_time = grow_time_per_stage

	_update_sprite()


## Xử lý khi người chơi bấm vào ô đất. Việc làm phụ thuộc vào trạng thái hiện tại.
func interact() -> void:
	match state:
		State.PLAIN:
			_set_state(State.TILLED)
		State.TILLED:
			_plant()
		State.MATURE:
			_harvest()
		_:
			pass # Đang lớn thì chưa làm được gì.


## Gieo hạt và bắt đầu đếm thời gian cây lớn.
func _plant() -> void:
	_set_state(State.SEED)
	grow_timer.start()


## Thu hoạch cây đã chín.
func _harvest() -> void:
	harvested.emit(crop_id)
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
	crop_sprite.texture = _stage_texture(STAGE_INDEX.get(state, -1))


## Lấy texture của giai đoạn cây. Trả về null nếu không có giai đoạn đó.
func _stage_texture(index: int) -> Texture2D:
	if index < 0 or index >= stage_textures.size():
		return null
	return stage_textures[index]
