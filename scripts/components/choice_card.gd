class_name ChoiceCard
extends PanelContainer

const MOUSE_POINTER_ID := -1

signal drag_pressed(card: Variant, pointer_position: Vector2, pointer_id: int)

const SELF_SCENE := preload("res://scenes/components/choice_card.tscn")

@onready var texture_rect: TextureRect = %ChoiceTexture
@onready var fallback_frame: Control = %FallbackFrame
@onready var fallback_glyph: Label = %FallbackGlyph
@onready var fallback_caption: Label = %FallbackCaption

var choice_id: String
var asset_path: String
var content_kind := "symbol"
var source_hidden := false


func _ready() -> void:
	_refresh_visual()


func set_choice_data(new_choice_id: String, new_asset_path: String, new_content_kind: String = "symbol") -> void:
	choice_id = new_choice_id
	asset_path = new_asset_path
	content_kind = _normalize_content_kind(new_content_kind)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	if is_node_ready():
		_refresh_visual()


func get_choice_id() -> String:
	return choice_id


func get_asset_path() -> String:
	return asset_path


func get_symbol_asset() -> String:
	return asset_path


func get_content_kind() -> String:
	return content_kind


func build_drag_proxy(source_size: Vector2) -> Control:
	var proxy = SELF_SCENE.instantiate()
	proxy.set_choice_data(choice_id, asset_path, content_kind)
	proxy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	proxy.z_index = 50
	proxy.custom_minimum_size = source_size
	proxy.size = source_size
	proxy.set_drag_proxy_state()
	return proxy


func set_drag_source_hidden(is_hidden: bool) -> void:
	source_hidden = is_hidden
	mouse_filter = Control.MOUSE_FILTER_IGNORE if is_hidden else Control.MOUSE_FILTER_STOP
	modulate = Color(1, 1, 1, 0.0) if is_hidden else Color(1, 1, 1, 1)


func set_drag_proxy_state() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale = Vector2.ONE
	modulate = Color(1, 1, 1, 1)


func disable_and_hide() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween := create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.18)
	tween.tween_callback(func() -> void:
		visible = false
	)


func set_slotted() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	scale = Vector2.ONE
	modulate = Color(0.9, 1.0, 0.9, 1.0)


func _gui_input(event: InputEvent) -> void:
	if source_hidden or mouse_filter == Control.MOUSE_FILTER_IGNORE:
		return

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			drag_pressed.emit(self, mouse_event.global_position, MOUSE_POINTER_ID)
			accept_event()
	elif event is InputEventScreenTouch and event.pressed:
		var touch_event := event as InputEventScreenTouch
		drag_pressed.emit(self, touch_event.position, touch_event.index)
		accept_event()


func _refresh_visual() -> void:
	if texture_rect == null or fallback_frame == null or fallback_glyph == null or fallback_caption == null:
		return

	var texture: Texture2D = null
	if not asset_path.is_empty() and ResourceLoader.exists(asset_path):
		texture = load(asset_path) as Texture2D

	texture_rect.texture = texture
	texture_rect.visible = texture != null
	fallback_frame.visible = texture == null
	fallback_glyph.text = _build_fallback_glyph(choice_id)
	fallback_caption.text = _build_fallback_caption(choice_id, content_kind)


func _build_fallback_glyph(source_id: String) -> String:
	if source_id.is_empty():
		return "?"
	return source_id.left(1).to_upper()


func _build_fallback_caption(source_id: String, source_content_kind: String) -> String:
	if source_id.is_empty():
		return "Picture" if source_content_kind == "picture" else "Symbol"
	return source_id.capitalize()


func _normalize_content_kind(raw_kind: String) -> String:
	if raw_kind == "picture":
		return "picture"
	return "symbol"
