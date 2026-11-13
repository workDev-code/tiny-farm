class_name GameUI
extends CanvasLayer

## Giao diện người chơi: tiền, trạng thái ô đất, kho hàng và thanh hạt giống.
##
## UI chỉ đọc và gọi hàm của `GameManager` (autoload), không tự lưu trạng thái game.

@onready var money_label: Label = $Money
@onready var status_label: Label = $Status
@onready var hint_label: Label = $Hint
@onready var inventory_label: Label = $Inventory
@onready var sell_button: Button = $BtnSell
@onready var upgrade_button: Button = $BtnUpgrade
@onready var carrot_button: SeedButton = $BtnCarrot
@onready var buy_carrot_button: SeedButton = $BtnBuyCarrot
@onready var corn_button: SeedButton = $BtnCorn
@onready var buy_corn_button: SeedButton = $BtnBuyCorn
@onready var tool_none_button: Button = $Toolbar/BtnToolNone
@onready var tool_hoe_button: Button = $Toolbar/BtnToolHoe
@onready var tool_seed_button: Button = $Toolbar/BtnToolSeed

var tool_manager: Node


func _ready() -> void:
	GameManager.money_changed.connect(_on_money_changed)
	GameManager.inventory_changed.connect(_on_inventory_changed)
	GameManager.selection_changed.connect(_on_selection_changed)
	GameManager.notice.connect(_on_notice)

	tool_manager = get_parent().get_node_or_null("ToolManager")
	carrot_button.pressed.connect(_on_seed_button.bind(carrot_button))
	buy_carrot_button.pressed.connect(_on_seed_button.bind(buy_carrot_button))
	corn_button.pressed.connect(_on_seed_button.bind(corn_button))
	buy_corn_button.pressed.connect(_on_seed_button.bind(buy_corn_button))
	tool_none_button.pressed.connect(_on_tool_button.bind(tool_manager.TOOL_NONE))
	tool_hoe_button.pressed.connect(_on_tool_button.bind(tool_manager.TOOL_HOE))
	tool_seed_button.pressed.connect(_on_tool_button.bind(tool_manager.TOOL_SEED))
	sell_button.pressed.connect(_on_sell_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)

	if tool_manager != null:
		tool_manager.tool_changed.connect(_on_tool_selected)
	_refresh()
	_refresh_tool_buttons()


## Hiển thị trạng thái ô đất vừa thao tác.
func set_status(text: String) -> void:
	status_label.text = text


func _on_seed_button(button: SeedButton) -> void:
	if button.action == "buy":
		GameManager.buy_seed(button.crop_id)
	else:
		GameManager.select_crop(button.crop_id)


func _on_tool_button(tool: int) -> void:
	if tool_manager != null:
		tool_manager.set_tool(tool)
	_refresh_tool_buttons()


func _on_tool_selected(_tool: int) -> void:
	_refresh_tool_buttons()


func _on_sell_pressed() -> void:
	GameManager.sell_all()


func _on_upgrade_pressed() -> void:
	GameManager.buy_upgrade()


func _on_money_changed(_money: int) -> void:
	_refresh()


func _on_inventory_changed() -> void:
	_refresh()


func _on_selection_changed(_crop_id: int) -> void:
	_refresh()


func _on_notice(text: String) -> void:
	hint_label.text = text


## Vẽ lại toàn bộ số liệu trên HUD.
func _refresh() -> void:
	money_label.text = "Tiền: %d xu" % GameManager.money
	inventory_label.text = _inventory_text()
	_refresh_tool_buttons()

	_update_select_button(carrot_button)
	_update_select_button(corn_button)
	_update_buy_button(buy_carrot_button)
	_update_buy_button(buy_corn_button)

	sell_button.text = "Bán hàng (+%d xu)" % GameManager.produce_value()
	upgrade_button.text = "Nâng cấp (%d xu)" % GameManager.upgrade_cost()
	upgrade_button.disabled = GameManager.upgrade_level >= GameManager.max_upgrade_level


func _update_select_button(button: SeedButton) -> void:
	var crop := GameManager.get_crop(button.crop_id)
	if crop == null:
		button.text = "?"
		return
	button.text = "%s ×%d" % [crop.display_name, GameManager.seeds[button.crop_id]]
	# Tooltip giải thích cây này: lớn bao lâu, bán được bao nhiêu.
	button.tooltip_text = "%s — lớn trong %ds, bán được %d xu" % [
		crop.display_name, int(crop.grow_time), crop.sell_price
	]
	# Ô đang được chọn sẽ sáng lên.
	if GameManager.selected_crop_id == button.crop_id:
		button.modulate = Color(1.0, 1.0, 0.55)
	else:
		button.modulate = Color.WHITE


func _update_buy_button(button: SeedButton) -> void:
	var crop := GameManager.get_crop(button.crop_id)
	if crop == null:
		button.text = "?"
		return
	button.text = "+%d xu" % crop.seed_price
	button.tooltip_text = "Mua 1 hạt giống %s" % crop.display_name
	# Không đủ tiền thì làm nút mờ đi để thấy ngay không mua được.
	button.disabled = GameManager.money < crop.seed_price
	# Đang chọn loại cây mà đã hết hạt -> nháy nút mua để gợi ý.
	var selected := GameManager.selected_crop_id == button.crop_id
	if selected and GameManager.seeds[button.crop_id] <= 0:
		button.modulate = Color(0.6, 1.0, 0.6)
	else:
		button.modulate = Color.WHITE


func _refresh_tool_buttons() -> void:
	if tool_manager == null:
		return
	tool_none_button.button_pressed = tool_manager.is_selected(tool_manager.TOOL_NONE)
	tool_hoe_button.button_pressed = tool_manager.is_selected(tool_manager.TOOL_HOE)
	tool_seed_button.button_pressed = tool_manager.is_selected(tool_manager.TOOL_SEED)
	tool_none_button.modulate = Color(1.0, 1.0, 1.0) if tool_manager.is_selected(tool_manager.TOOL_NONE) else Color(0.75, 0.75, 0.75)
	tool_hoe_button.modulate = Color(1.0, 0.82, 0.35) if tool_manager.is_selected(tool_manager.TOOL_HOE) else Color(1.0, 1.0, 1.0)
	tool_seed_button.modulate = Color(0.8, 1.0, 0.8) if tool_manager.is_selected(tool_manager.TOOL_SEED) else Color(1.0, 1.0, 1.0)


func _inventory_text() -> String:
	var parts: Array[String] = []
	for i in GameManager.crops.size():
		if GameManager.produce[i] > 0:
			parts.append("%s ×%d" % [GameManager.crops[i].display_name, GameManager.produce[i]])
	if parts.is_empty():
		return "Kho: trống"
	return "Kho: " + ", ".join(parts)
