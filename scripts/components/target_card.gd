extends PanelContainer

@onready var texture_rect: TextureRect = %ContentTexture
@onready var fallback_frame: Control = %FallbackFrame
@onready var fallback_glyph: Label = %FallbackGlyph
@onready var fallback_caption: Label = %FallbackCaption
@onready var placed_card_anchor: Control = %PlacedCardAnchor

const BASE_TEXTURE_SIZE := Vector2(320, 320)

var current_concept_id := ""
var current_asset_path := ""
var current_content_kind := "picture"
var current_visual_scale := 1.0
var expected_choice_id := ""
var is_filled := false


func set_content(
	concept_id: String,
	asset_path: String,
	content_kind: String = "picture",
	visual_scale: float = 1.0
) -> void:
	current_concept_id = concept_id
	current_asset_path = asset_path
	current_content_kind = _normalize_content_kind(content_kind)
	current_visual_scale = clampf(visual_scale, 0.35, 1.0)
	if not is_node_ready():
		return

	var texture: Texture2D = null
	if not current_asset_path.is_empty() and ResourceLoader.exists(current_asset_path):
		texture = load(current_asset_path) as Texture2D

	texture_rect.texture = texture
	texture_rect.custom_minimum_size = BASE_TEXTURE_SIZE * current_visual_scale
	texture_rect.visible = texture != null
	fallback_frame.visible = texture == null
	fallback_glyph.text = _build_fallback_glyph(current_concept_id)
	fallback_caption.text = _build_fallback_caption(current_concept_id, current_content_kind)


func set_expected_choice(choice_id: String) -> void:
	expected_choice_id = choice_id
	is_filled = false
	if not is_node_ready():
		return

	modulate = Color(1, 1, 1, 1)


func set_filled(_choice_id: String, _asset_path: String = "", _content_kind: String = "") -> void:
	is_filled = true
	if not is_node_ready():
		return

	modulate = Color(0.96, 1.0, 0.96, 1.0)


func _ready() -> void:
	set_content(current_concept_id, current_asset_path, current_content_kind, current_visual_scale)


func set_drag_target_ready(is_ready: bool) -> void:
	if is_filled:
		modulate = Color(0.96, 1.0, 0.96, 1.0)
		return
	modulate = Color(0.98, 0.98, 1.0, 1.0) if is_ready else Color(1, 1, 1, 1)


func accepts_global_drop(global_position: Vector2) -> bool:
	return get_global_rect().has_point(global_position)


func get_settle_global_position(card_size: Vector2) -> Vector2:
	var anchor_rect := placed_card_anchor.get_global_rect()
	return anchor_rect.position + ((anchor_rect.size - card_size) * 0.5)


func _build_fallback_glyph(source_id: String) -> String:
	if source_id.is_empty():
		return "?"
	return source_id.left(1).to_upper()


func _build_fallback_caption(source_id: String, source_content_kind: String) -> String:
	if source_id.is_empty():
		return "Symbol" if source_content_kind == "symbol" else "Picture"
	return source_id.capitalize()


func _normalize_content_kind(raw_kind: String) -> String:
	if raw_kind == "symbol":
		return "symbol"
	return "picture"
