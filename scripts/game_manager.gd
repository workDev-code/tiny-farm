extends Node

## Quản lý tiền, hạt giống, nông sản và các nâng cấp của người chơi.
##
## Node này được đăng ký là Autoload trong `project.godot`, nên có thể gọi
## `GameManager.xxx` từ mọi nơi. Vì vậy script này KHÔNG khai báo `class_name`
## (trùng tên với autoload sẽ gây lỗi parse).

signal money_changed(money: int)
signal inventory_changed()
signal selection_changed(crop_id: int)
signal notice(text: String)

## Danh sách loại cây trồng của game.
@export var crops: Array[CropData] = []
## Số tiền người chơi bắt đầu.
@export var starting_money: int = 100
## Số hạt giống khởi đầu cho từng loại cây, theo thứ tự trong `crops`.
## Ô trống (hoặc thiếu phần tử) nghĩa là loại cây đó không có hạt giống sẵn.
@export var starting_seeds: Array[int] = [2, 1]
## Số lần nâng cấp tối đa.
@export var max_upgrade_level: int = 3
## Giá nâng cấp cấp 1, mỗi lần nâng cấp tiếp theo đắt hơn.
@export var upgrade_base_cost: int = 100
## Mỗi lần nâng cấp, cây mọc nhanh thêm phần trăm này.
@export var upgrade_speed_percent: int = 20

var money: int = 0
## Số hạt giống đang có, theo chỉ số là id của cây.
var seeds: Array[int] = []
## Số nông sản trong kho, theo chỉ số là id của cây.
var produce: Array[int] = []
## Loại cây đang được chọn để trồng.
var selected_crop_id: int = -1
var upgrade_level: int = 0
## Hệ số tốc độ mọc. 1.0 = bình thường, 1.2 = nhanh hơn 20%.
var growth_speed: float = 1.0


func _ready() -> void:
	money = starting_money
	seeds.resize(crops.size())
	produce.resize(crops.size())
	for i in crops.size():
		seeds[i] = starting_seeds[i] if i < starting_seeds.size() else 0
		produce[i] = 0

	# Chọn sẵn loại cây đầu tiên để người chơi bắt đầu được ngay.
	if crops.size() > 0:
		selected_crop_id = 0

	money_changed.emit(money)
	inventory_changed.emit()
	selection_changed.emit(selected_crop_id)


## Lấy dữ liệu cây theo id. Trả về null nếu id không hợp lệ.
func get_crop(crop_id: int) -> CropData:
	if crop_id < 0 or crop_id >= crops.size():
		return null
	return crops[crop_id]


## Mua 1 hạt giống. Trả về false nếu không đủ tiền.
func buy_seed(crop_id: int) -> bool:
	var crop := get_crop(crop_id)
	if crop == null:
		return false
	if money < crop.seed_price:
		notice.emit("Không đủ tiền để mua hạt giống %s" % crop.display_name)
		return false

	money -= crop.seed_price
	seeds[crop_id] += 1
	selected_crop_id = crop_id

	money_changed.emit(money)
	inventory_changed.emit()
	selection_changed.emit(selected_crop_id)
	notice.emit("Đã mua 1 hạt giống %s (-%d xu)" % [crop.display_name, crop.seed_price])
	return true


## Chọn loại hạt giống sẽ được trồng.
func select_crop(crop_id: int) -> void:
	if get_crop(crop_id) == null:
		return
	selected_crop_id = crop_id
	selection_changed.emit(crop_id)


## Lấy 1 hạt giống đang chọn để trồng. Trả về null nếu không có hạt giống.
func take_selected_seed() -> CropData:
	if selected_crop_id < 0:
		notice.emit("Hãy chọn loại hạt giống ở thanh dưới màn hình trước")
		return null
	if seeds[selected_crop_id] <= 0:
		notice.emit("Không còn hạt giống %s — hãy mua thêm" % crops[selected_crop_id].display_name)
		return null

	seeds[selected_crop_id] -= 1
	inventory_changed.emit()
	return crops[selected_crop_id]


## Cộng nông sản vào kho.
func add_produce(crop_id: int, amount: int = 1) -> void:
	if crop_id < 0 or crop_id >= produce.size():
		return
	produce[crop_id] += amount
	inventory_changed.emit()


## Tổng giá trị nông sản đang có trong kho.
func produce_value() -> int:
	var total := 0
	for i in crops.size():
		total += produce[i] * crops[i].sell_price
	return total


## Bán toàn bộ nông sản trong kho. Trả về số tiền thu được.
func sell_all() -> int:
	var total := produce_value()
	if total <= 0:
		notice.emit("Kho đang trống, không có gì để bán")
		return 0

	for i in produce.size():
		produce[i] = 0
	money += total

	money_changed.emit(money)
	inventory_changed.emit()
	notice.emit("Đã bán nông sản, nhận %d xu" % total)
	return total


## Giá của lần nâng cấp tiếp theo.
func upgrade_cost() -> int:
	return upgrade_base_cost * (upgrade_level + 1)


## Mua nâng cấp tốc độ mọc.
func buy_upgrade() -> bool:
	if upgrade_level >= max_upgrade_level:
		notice.emit("Đã nâng cấp tối đa rồi")
		return false

	var cost := upgrade_cost()
	if money < cost:
		notice.emit("Không đủ tiền để nâng cấp (cần %d xu)" % cost)
		return false

	money -= cost
	upgrade_level += 1
	growth_speed = 1.0 + float(upgrade_speed_percent * upgrade_level) / 100.0

	money_changed.emit(money)
	notice.emit("Nâng cấp xong! Cây mọc nhanh hơn %d%%" % int((growth_speed - 1.0) * 100))
	return true
