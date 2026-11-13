extends Node

## Dữ liệu và hành vi của một ô đất theo Tool + Soil state.
## Feature 01 chỉ hỗ trợ PLAIN/TILLED và 3 công cụ: NONE, HOE, SEED.

enum SoilState {
	PLAIN,
	TILLED,
}

@export var plain_texture: Texture2D
@export var tilled_texture: Texture2D

var soil_state: SoilState = SoilState.PLAIN

@onready var soil_sprite: Sprite2D = get_parent().get_node("Soil")


func _ready() -> void:
	_sync_sprite()


func apply_tool(tool: int) -> bool:
	if tool == 1:
		if soil_state == SoilState.PLAIN:
			soil_state = SoilState.TILLED
			_sync_sprite()
			return true
		return false
	return false


func _sync_sprite() -> void:
	if soil_sprite == null:
		return
	soil_sprite.texture = plain_texture if soil_state == SoilState.PLAIN else tilled_texture
