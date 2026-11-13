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

## Approach B: thời gian gieo hạt (unix timestamp). Dùng để tính offline.
var planted_at := 0.0
## Tổng thời gian lớn của cây này, được ghi lại chính lúc gieo (không đổi).
## Không dùng grow_time của CropData hiện tại — vì upgrade có thể thay đổi sau khi gieo.
var grow_duration := 0.0


func _ready() -> void:
	# input_event chỉ phát ra khi Area2D có "input_pickable" bật (mặc định đã bật).
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	grow_timer.timeout.connect(_on_timer_timeout)

	_update_sprite()


## Trả về Dictionary để SaveManager ghi vào file (Approach B).
func get_save_data() -> Dictionary:
	if crop == null:
		return {"crop_id": -1}
	return {
		"crop_id": int(crop.id),
		"planted_at": planted_at,
		"grow_duration": grow_duration,
	}


## Khôi phục từ file save (Approach B): tính state từ thời gian thực tế.
func load_from_save(data: Dictionary, crops: Array) -> void:
	var crop_id := int(data.get("crop_id", -1))
	if crop_id < 0 or crop_id >= crops.size():
		# Không có cây: ô đất trống.
		crop = null
		state = State.PLAIN
		grow_timer.stop()
		_update_sprite()
		return

	crop = crops[crop_id]
	planted_at = float(data.get("planted_at", 0.0))
	grow_duration = float(data.get("grow_duration", 0.0))
	if grow_duration <= 0.0:
		# Dữ liệu không hợp lệ: coi như mới gieo.
		planted_at = Time.get_unix_time_from_system()
		grow_duration = crop.grow_time

	# Approach B: tính state từ thời gian đã trôi.
	var now := Time.get_unix_time_from_system()
	var elapsed := now - planted_at
	var progress := elapsed / maxf(grow_duration, 0.01)

	if progress >= 1.0:
		# Đã chín từ lâu — giữ nguyên ở MATURE, không tự thu hoạch.
		state = State.MATURE
		grow_timer.stop()
	else:
		# Chọn giai đoạn: 4 giai đoạn tương ứng SEED..MATURE.
		var stage_index := int(progress * 4.0)
		if stage_index < 0:
			stage_index = 0
		if stage_index > 3:
			stage_index = 3
		# Enum: PLAIN=0, TILLED=1, SEED=2, SPROUT=3, GROWING=4, MATURE=5
		state = State.SEED + stage_index
		# Đặt timer để fire đúng lúc kết thúc giai đoạn hiện tại.
		var stage_time := grow_duration / 4.0
		var time_in_current := elapsed - stage_index * stage_time
		grow_timer.wait_time = stage_time - time_in_current
		grow_timer.start()

	_update_sprite()
	state_changed.emit(state)


## Số giây còn lại cho tới khi cây chín.
## Dùng để hiển thị đồng hồ đếm ngược trên UI.
func time_to_mature() -> float:
	if crop == null or not STAGE_INDEX.has(state):
		return 0.0
	# Tu giai doan hien tai toi MATURE con it nhip timer nua.
	var transitions: int = 3 - int(STAGE_INDEX[state])
	return grow_timer.time_left + float(maxi(transitions - 1, 0)) * grow_timer.wait_time


## Trồng một loại cây lên ô đất.
## `speed` là hệ số tốc độ mọc (>1 = nhanh hơn).
func plant(new_crop: CropData, speed: float = 1.0) -> void:
	crop = new_crop
	# grow_duration = tổng thời gian lớn của cây này, ghi lại ngay lúc gieo.
	# Không dùng crop.grow_time trực tiếp — phải chia cho speed (nâng cấp).
	grow_duration = crop.grow_time / maxf(speed, 0.01)
	planted_at = Time.get_unix_time_from_system()
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
##
## Approach B: timer fire là để làm mới state theo thời gian thực, không phải là
## nguồn sự thật. Khi fire, kiểm tra xem đã tới giai đoạn tiếp theo chưa.
func _on_timer_timeout() -> void:
	var now := Time.get_unix_time_from_system()
	var elapsed := now - planted_at
	var progress := elapsed / maxf(grow_duration, 0.01)

	# Nếu đã tới MATURE thì dừng timer, không tự thu hoạch.
	if progress >= 1.0:
		if state != State.MATURE:
			_set_state(State.MATURE)
		grow_timer.stop()
		return

	# Tính giai đoạn theo progress, so sánh với state hiện tại.
	var stage_index := int(progress * 4.0)
	if stage_index < 0: stage_index = 0
	if stage_index > 3: stage_index = 3
	var target_state := State.SEED + stage_index

	if target_state != state:
		_set_state(target_state)

	# Đặt timer fire lần tiếp theo = kết thúc giai đoạn hiện tại.
	var stage_time := grow_duration / 4.0
	var time_in_current := elapsed - stage_index * stage_time
	var next_fire := stage_time - time_in_current
	if next_fire < 0.05:
		next_fire = 0.05
	grow_timer.wait_time = next_fire
	grow_timer.start()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# Chỉ quan tâm tới cú nhấn chuột trái.
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			var tool_manager = _get_tool_manager()
			if tool_manager != null and tool_manager.selected_tool != tool_manager.TOOL_NONE:
				return
			interact()


func _on_mouse_entered() -> void:
	# Sáng nhẹ ô đất khi rê chuột vào, để người chơi biết ô nào đang chọn.
	# modulate trên node gốc sẽ áp dụng cho cả Soil lẫn Crop.
	modulate = Color(1.25, 1.25, 1.25)


func _on_mouse_exited() -> void:
	modulate = Color.WHITE


func _get_tool_manager():
	var main := get_tree().get_root().get_node_or_null("Main")
	if main == null:
		return null
	return main.get_node_or_null("ToolManager")


func _update_sprite() -> void:
	# Nền đất: trống thì lộ cỏ, đã cày thì hiện đất tilled (giữ nguyên tới khi thu hoạch).
	soil_sprite.texture = plain_texture if state == State.PLAIN else tilled_texture

	# Cây: chỉ hiện từ lúc gieo hạt, đè lên nền đất.
	if crop == null or not STAGE_INDEX.has(state):
		crop_sprite.texture = null
		return
	crop_sprite.texture = crop.stage_textures[STAGE_INDEX[state]]
