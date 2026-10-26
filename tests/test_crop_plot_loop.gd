extends SceneTree

## Kiểm thử vòng đời ô đất: cày -> gieo hạt -> lớn dần -> chín -> thu hoạch.
##
## Chạy:  godot --path . --script tests/test_crop_plot_loop.gd
## Kết quả: in "PASS" / "FAIL" cho từng bước, thoát với mã 0 nếu tất cả đạt.

const GROW_TIME := 2.0

var scene: Node
var plot: Node
var failed := 0


func _initialize() -> void:
	scene = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	plot = scene.get_node("Farm/Plot")

	await _frames(4)
	_check("bat dau o trang thai PLAIN", plot.state == 0)

	await _click()
	_check("click 1: PLAIN -> TILLED", plot.state == 1)

	await _click()
	_check("click 2: TILLED -> SEED", plot.state == 2)

	# Click lúc đang lớn phải không làm gì.
	await _click()
	_check("click khi dang lon: khong doi trang thai", plot.state == 2)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("het gio -> SPROUT", plot.state == 3)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("het gio -> GROWING", plot.state == 4)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("het gio -> MATURE", plot.state == 5)

	# Timer phai dung sau khi chin, khong du chuyen tiep.
	await create_timer(GROW_TIME + 0.4).timeout
	_check("timer da dung: van o MATURE", plot.state == 5)

	await _click()
	_check("click 3: MATURE -> PLAIN (thu hoach)", plot.state == 0)
	_check("kho nhan duoc 1 qua thu hoach", scene.inventory == 1)

	print("")
	if failed == 0:
		print("PASS — tat ca deu dung.")
	else:
		print("FAIL — %d truong hop sai." % failed)
	quit(1 if failed > 0 else 0)


func _check(label: String, ok: bool) -> void:
	if ok:
		print("  PASS  ", label)
	else:
		failed += 1
		print("  FAIL  ", label)


func _click() -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = Vector2(320, 180)
	press.global_position = Vector2(320, 180)
	root.push_input(press, true)
	await _frames(2)


func _frames(count: int) -> void:
	for i in count:
		await process_frame
