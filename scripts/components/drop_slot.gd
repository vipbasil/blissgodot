extends PanelContainer

signal choice_dropped(choice_id: String)

@onready var texture_rect: TextureRect = %SlotTexture
@onready var empty_state: Control = %EmptyState
@onready var icon_label: Label = %IconLabel
@onready var hint_label: Label = %HintLabel
@onready var filled_label: Label = %FilledLabel

var expected_choice_id: String = ""
var is_filled := false
var filled_choice_id := ""
var filled_symbol_asset := ""


func set_expected_choice(choice_id: String) -> void:
    expected_choice_id = choice_id
    is_filled = false
    filled_choice_id = ""
    filled_symbol_asset = ""
    if not is_node_ready():
        return

    texture_rect.texture = null
    texture_rect.visible = false
    empty_state.visible = true
    filled_label.visible = false
    icon_label.text = "+"
    hint_label.text = "Place the match"
    modulate = Color(1, 1, 1, 1)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
    var accepted := typeof(data) == TYPE_DICTIONARY and String(data.get("choice_id", "")) != ""
    if accepted and not is_filled:
        modulate = Color(0.95, 0.98, 1.0, 1.0)
    return accepted


func _drop_data(_at_position: Vector2, data: Variant) -> void:
    modulate = Color(1, 1, 1, 1)
    choice_dropped.emit(String(data.get("choice_id", "")))


func set_filled(choice_id: String, symbol_asset: String) -> void:
    is_filled = true
    filled_choice_id = choice_id
    filled_symbol_asset = symbol_asset
    if not is_node_ready():
        return

    var texture: Texture2D = null
    if not filled_symbol_asset.is_empty() and ResourceLoader.exists(filled_symbol_asset):
        texture = load(filled_symbol_asset) as Texture2D

    texture_rect.texture = texture
    texture_rect.visible = texture != null
    empty_state.visible = false
    filled_label.visible = texture == null
    filled_label.text = filled_choice_id.capitalize()
    modulate = Color(0.9, 1.0, 0.9, 1.0)


func _notification(what: int) -> void:
    if what == NOTIFICATION_DRAG_END and not is_filled:
        modulate = Color(1, 1, 1, 1)


func _ready() -> void:
    if is_filled:
        set_filled(filled_choice_id, filled_symbol_asset)
    else:
        set_expected_choice(expected_choice_id)
