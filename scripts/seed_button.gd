class_name SeedButton
extends Button

## Nút cho hạt giống.
##
## `action` có 2 giá trị:
##   "select" — chọn loại hạt giống sẽ được trồng
##   "buy"    — mua thêm 1 hạt giống

@export var crop_id: int = 0
@export var action: String = "select"
