extends SceneTree

## Kiểm thử lưới 9 ô đất và vòng đời của một ô: cày -> gieo hạt -> lớn -> chín -> thu hoạch.
##
## Chạy:  godot --path . --script tests/test_crop_plot_loop.gd
## Kết quả: in "PASS" / "FAIL" cho từng bước, thoát với mã 0 nếu tất cả đạt.

const GROW_TIME := 2.0
const P1 := Vector2(248, 108)
const P2 := Vector2(320, 108)

var scene: Node
var plots: Node
var failed := 0


func _initialize() -> void:
	scene = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	plots = scene.get_node("Farm/Plots")

	await _frames(4)
	_check("luoi co 9 o dat", plots.get_child_count() == 9)

	var plot1 := plots.get_node("Plot_1") as CropPlot
	var plot2 := plots.get_node("Plot_2") as CropPlot

	# --- Vong doi cua o Plot_1 ---
	_check("Plot_1 bat dau o PLAIN", plot1.state == 0)

	await _click(P1)
	_check("Plot_1: PLAIN -> TILLED", plot1.state == 1)
	_check("Plot_2 khong bi anh huong", plot2.state == 0)

	await _click(P1)
	_check("Plot_1: TILLED -> SEED", plot1.state == 2)

	# Click luc dang lon phai khong lam gi.
	await _click(P1)
	_check("Plot_1: click khi dang lon khong doi trang thai", plot1.state == 2)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("Plot_1: het gio -> SPROUT", plot1.state == 3)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("Plot_1: het gio -> GROWING", plot1.state == 4)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("Plot_1: het gio -> MATURE", plot1.state == 5)

	# Timer phai dung sau khi chin.
	await create_timer(GROW_TIME + 0.4).timeout
	_check("Plot_1: timer da dung, van o MATURE", plot1.state == 5)

	await _click(P1)
	_check("Plot_1: MATURE -> PLAIN (thu hoach)", plot1.state == 0)
	_check("kho nhan duoc 1 qua thu hoach", scene.inventory == 1)

	# --- Hai o lon doc lap nhau ---
	await _click(P1)
	await _click(P1)
	await create_timer(GROW_TIME + 0.2).timeout
	await _click(P2)
	await _click(P2)
	_check("Plot_1 o SPROUT, Plot_2 o SEED - hai timer chay doc lap",
		plot1.state == 3 and plot2.state == 2)

	await create_timer(GROW_TIME + 0.2).timeout
	_check("hai o o giai doan khac nhau", plot1.state == 4 and plot2.state == 3)

	# Tu SPROUT toi MATURE can 2 nhip (4 giay).
	await create_timer(GROW_TIME * 2 + 0.2).timeout
	_check("Plot_1 va Plot_2 deu MATURE", plot1.state == 5 and plot2.state == 5)

	await _click(P2)
	_check("Plot_2: MATURE -> PLAIN (thu hoach)", plot2.state == 0)
	_check("Plot_1 van MATURE", plot1.state == 5)
	_check("kho nhan duoc 2 qua thu hoach", scene.inventory == 2)

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


func _click(pos: Vector2) -> void:
	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	root.push_input(press, true)
	await _frames(2)


func _frames(count: int) -> void:
	for i in count:
		await process_frame
