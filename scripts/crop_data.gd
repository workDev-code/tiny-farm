class_name CropData
extends Resource

## Dữ liệu của một loại cây trồng.
##
## Mỗi loại cây là một file .tres trong `resources/crops/`.
## Thêm loại cây mới = thêm file .tres, không phải sửa code.

## Mã định danh, dùng làm chỉ số trong kho hạt giống và kho nông sản.
@export var id: int = 0
## Tên hiển thị cho người chơi.
@export var display_name: String = "Cây trồng"
## Giá mua 1 hạt giống.
@export var seed_price: int = 10
## Giá bán 1 sản phẩm thu hoạch được.
@export var sell_price: int = 30
## Tổng thời gian từ lúc gieo hạt tới khi chín (giây).
@export var grow_time: float = 6.0
## Hình ảnh từng giai đoạn: [vừa gieo, nảy mầm, đang lớn, đã chín].
@export var stage_textures: Array[Texture2D] = []


## Thời gian của một giai đoạn (giây).
func time_per_stage() -> float:
	if stage_textures.is_empty():
		return grow_time
	return grow_time / float(stage_textures.size())
