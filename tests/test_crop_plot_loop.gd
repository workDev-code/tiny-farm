extends SceneTree

## Kiểm thử lưới 9 ô đất, vòng đời cây trồng và toàn bộ vòng lặp kinh tế.
##
## Chạy:  godot --path . --script tests/test_crop_plot_loop.gd
## Kết quả: in "PASS" / "FAIL" cho từng bước, thoát với mã 0 nếu tất cả đạt.

# Ca rot: 6 giay tieu chinh / 4 giai doan = 1.5 giay moi giai doan
const CARROT_GROW := 6.0
const CARROT_STAGE := CARROT_GROW / 4.0
# Ngo: 15 giay tieu chinh / 4 giai doan = 3.75 giay moi giai doan
const CORN_GROW := 15.0
const P1 := Vector2(248, 108)
const P2 := Vector2(320, 108)
const P3 := Vector2(392, 108)
# Toa do cac nut tren HUD (viewport 640x360)
const BTN_CARROT := Vector2(48, 330)
const BTN_BUY_CORN := Vector2(230, 330)
const BTN_SELL := Vector2(551, 18)
const BTN_UPGRADE := Vector2(551, 42)

var scene: Node
var plots: Node
var gm: Node
var failed := 0


func _initialize() -> void:
	# Trong chế độ `--script`, tên autoload chưa được đăng ký thành identifier
	# lúc biên dịch, nên phải lấy node bằng đường dẫn.
	gm = root.get_node("GameManager")
	scene = (load("res://scenes/Main.tscn") as PackedScene).instantiate()
	root.add_child(scene)
	plots = scene.get_node("Farm/Plots")

	await _frames(4)
	_check("luoi co 9 o dat", plots.get_child_count() == 9)

	# Chuẩn bị đủ hạt giống cho phần kiểm thử vòng đời cây.
	gm.money = 1000
	for i in 5:
		gm.buy_seed(0)
	gm.select_crop(0)

	var plot1 := plots.get_node("Plot_1") as CropPlot
	var plot2 := plots.get_node("Plot_2") as CropPlot

	# --- Vong doi cua o Plot_1 ---
	_check("Plot_1 bat dau o PLAIN", plot1.state == 0)

	await _click(P1)
	_check("Plot_1: PLAIN -> TILLED", plot1.state == 1)
	_check("Plot_2 khong bi anh huong", plot2.state == 0)

	await _click(P1)
	_check("Plot_1: TILLED -> SEED", plot1.state == 2)
	_check("cay trong la ca rot", plot1.crop != null and plot1.crop.id == 0)

	# Click luc dang lon phai khong lam gi.
	await _click(P1)
	_check("Plot_1: click khi dang lon khong doi trang thai", plot1.state == 2)

	await create_timer(CARROT_STAGE + 0.2).timeout
	_check("Plot_1: het gio -> SPROUT", plot1.state == 3)

	await create_timer(CARROT_STAGE + 0.2).timeout
	_check("Plot_1: het gio -> GROWING", plot1.state == 4)

	await create_timer(CARROT_STAGE + 0.2).timeout
	_check("Plot_1: het gio -> MATURE", plot1.state == 5)

	# Timer phai dung sau khi chin.
	await create_timer(CARROT_STAGE + 0.4).timeout
	_check("Plot_1: timer da dung, van o MATURE", plot1.state == 5)

	await _click(P1)
	_check("Plot_1: MATURE -> PLAIN (thu hoach)", plot1.state == 0)
	_check("Plot_1 het crop sau khi thu hoach", plot1.crop == null)

	# --- Hai o lon doc lap nhau ---
	await _click(P1)
	await _click(P1)
	await create_timer(CARROT_STAGE + 0.2).timeout
	await _click(P2)
	await _click(P2)
	_check("Plot_1 o SPROUT, Plot_2 o SEED - hai timer chay doc lap",
		plot1.state == 3 and plot2.state == 2)

	await create_timer(CARROT_STAGE + 0.2).timeout
	_check("hai o o giai doan khac nhau (Plot_1 tien hon Plot_2)",
		plot1.state > plot2.state)

	await create_timer(CARROT_STAGE * 2 + 0.2).timeout
	_check("Plot_1 va Plot_2 deu MATURE", plot1.state == 5 and plot2.state == 5)

	await _click(P2)
	_check("Plot_2: MATURE -> PLAIN (thu hoach)", plot2.state == 0)
	_check("Plot_1 van MATURE", plot1.state == 5)

	# --- Vong lap kinh te: dat lai trang thai ve mac dinh ---
	gm.money = 100
	gm.seeds[0] = 2
	gm.seeds[1] = 0
	gm.produce[0] = 0
	gm.produce[1] = 0
	gm.select_crop(0)
	_check("dat lai: 100 xu, 2 hat giong ca rot", gm.money == 100 and gm.seeds[0] == 2)

	# Mua hat giong ngo — BAM NUT THAT tren HUD
	await _click(BTN_BUY_CORN)
	_check("bam nut mua ngo: tien 100 -> 75", gm.money == 75)
	_check("mua xong co 1 hat giong ngo", gm.seeds[1] == 1)
	_check("mua xong ngo duoc chon", gm.selected_crop_id == 1)

	# Trong cay ngo vao Plot_3 (mot o chua dung den)
	var plot3 := plots.get_node("Plot_3") as CropPlot
	await _click(P3)
	await _click(P3)
	_check("Plot_3 da gieo hat", plot3.state == 2)
	_check("da tru 1 hat giong ngo", gm.seeds[1] == 0)
	_check("cay trong la ngo", plot3.crop != null and plot3.crop.id == 1)
	_check("thoi gian moi giai doan cua ngo = 3.75s",
		is_equal_approx(plot3.grow_timer.wait_time, CORN_GROW / 4.0))

	await create_timer(CORN_GROW + 1.0).timeout
	_check("cay ngo da chin", plot3.state == 5)

	await _click(P3)
	_check("thu hoach xong, o ve PLAIN", plot3.state == 0)
	_check("kho co 1 san pham ngo", gm.produce[1] == 1)
	_check("gia tri nong san = 90 xu", gm.produce_value() == 90)

	# Ban hang — BAM NUT THAT
	await _click(BTN_SELL)
	_check("bam nut ban hang: tien 75 -> 165", gm.money == 165)
	_check("kho da trong sau khi ban", gm.produce_value() == 0)

	# Nang cap toc do moc — BAM NUT THAT
	await _click(BTN_UPGRADE)
	_check("bam nut nang cap: tien 165 -> 65", gm.money == 65)
	_check("toc do moc tang 20%", is_equal_approx(gm.growth_speed, 1.2))

	# Chon hat giong bang nut
	await _click(BTN_CARROT)
	_check("bam nut chon ca rot: selected = 0", gm.selected_crop_id == 0)

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
	# Phai gui InputEventMouseMotion truoc: Godot can biet con tro dang o dau
	# moi xac dinh duoc Control nao duoc bam.
	# Gui 2 lan: lan dau co the bi GUI bo qua, lam click khong an.
	for i in 2:
		var motion := InputEventMouseMotion.new()
		motion.position = pos
		motion.global_position = pos
		root.push_input(motion, true)
		await _frames(2)

	var press := InputEventMouseButton.new()
	press.button_index = MOUSE_BUTTON_LEFT
	press.pressed = true
	press.position = pos
	press.global_position = pos
	root.push_input(press, true)
	await _frames(2)

	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	release.position = pos
	release.global_position = pos
	root.push_input(release, true)
	await _frames(2)


func _frames(count: int) -> void:
	for i in count:
		await process_frame
