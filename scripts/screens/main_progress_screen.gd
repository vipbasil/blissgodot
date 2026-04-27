extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

const LAYOUT_BY_COUNT := {
	1: [Vector2(0.50, 0.52)],
	2: [Vector2(0.32, 0.62), Vector2(0.68, 0.34)],
	3: [Vector2(0.25, 0.70), Vector2(0.54, 0.48), Vector2(0.76, 0.24)],
	4: [Vector2(0.20, 0.72), Vector2(0.46, 0.56), Vector2(0.74, 0.36), Vector2(0.54, 0.16)],
	5: [
		Vector2(0.16, 0.76),
		Vector2(0.42, 0.62),
		Vector2(0.72, 0.46),
		Vector2(0.56, 0.26),
		Vector2(0.28, 0.12),
	],
}

@onready var title_label: Label = %TitleLabel
@onready var focus_label: Label = %FocusLabel
@onready var hint_label: Label = %HintLabel
@onready var play_button: Button = %PlayButton
@onready var parent_button: Button = %ParentButton
@onready var path_area: Control = %PathArea
@onready var path_line: Line2D = %PathLine
@onready var node_buttons: Array[Button] = [
	%NodeButton0,
	%NodeButton1,
	%NodeButton2,
	%NodeButton3,
	%NodeButton4,
]

var progress_payload: Dictionary = {}
var nodes: Array[Dictionary] = []
var focused_node_id := ""
var locked_hint_default := "Keep moving along the path."


func initialize(payload: Dictionary) -> void:
	progress_payload = payload.duplicate(true)


func _ready() -> void:
	for index in node_buttons.size():
		node_buttons[index].pressed.connect(_on_node_pressed.bind(index))

	play_button.pressed.connect(_on_play_pressed)
	parent_button.pressed.connect(_on_parent_pressed)
	_render()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_node_ready():
		_update_path_layout()


func _render() -> void:
	nodes = _extract_nodes(progress_payload.get("nodes", []))
	focused_node_id = _resolve_initial_focus_id()

	var just_completed_node_id: String = String(progress_payload.get("just_completed_node_id", ""))
	title_label.text = "Your Path"
	if not just_completed_node_id.is_empty():
		title_label.text = "Nice Work"

	_update_path_layout()
	_update_focus_ui()


func _update_path_layout() -> void:
	if not is_node_ready():
		return

	var layout_points: Array = LAYOUT_BY_COUNT.get(nodes.size(), LAYOUT_BY_COUNT.get(1, []))
	path_line.clear_points()

	for index in node_buttons.size():
		var button: Button = node_buttons[index]
		if index >= nodes.size():
			button.visible = false
			continue

		var node: Dictionary = nodes[index]
		var is_focused: bool = String(node.get("node_id", "")) == focused_node_id
		var center := _resolve_point(path_area.size, layout_points[index])
		var diameter: float = _get_node_diameter(node, is_focused)
		button.visible = true
		button.size = Vector2.ONE * diameter
		button.position = center - (button.size * 0.5)
		button.pivot_offset = button.size * 0.5
		button.text = str(int(node.get("display_order", index + 1)))
		_apply_node_style(button, node, is_focused)
		path_line.add_point(center)


func _update_focus_ui() -> void:
	var focused_node: Dictionary = _get_node_by_id(focused_node_id)
	if focused_node.is_empty():
		focus_label.text = "Play the next calm step."
		hint_label.text = locked_hint_default
		play_button.disabled = true
		play_button.text = "Play"
		return

	var state: String = String(focused_node.get("state", "locked"))
	var category_label: String = _build_category_label(focused_node)
	play_button.disabled = not _is_playable_state(state)
	play_button.text = "Replay" if state == "completed" else "Play"
	focus_label.text = category_label
	hint_label.text = _build_hint_text(state)
	_update_path_layout()


func _on_node_pressed(index: int) -> void:
	if index >= nodes.size():
		return

	var node: Dictionary = nodes[index]
	var node_id: String = String(node.get("node_id", ""))
	var state: String = String(node.get("state", "locked"))

	if not _is_playable_state(state):
		hint_label.text = "This step opens after the one before it."
		_pulse_node(index)
		return

	if focused_node_id == node_id:
		_launch_node(node_id)
		return

	focused_node_id = node_id
	_update_focus_ui()


func _on_play_pressed() -> void:
	if focused_node_id.is_empty():
		return
	_launch_node(focused_node_id)


func _on_parent_pressed() -> void:
	navigate_requested.emit("parent_gate", {})


func _launch_node(node_id: String) -> void:
	navigate_requested.emit("session", {
		"node_id": node_id,
	})


func _resolve_initial_focus_id() -> String:
	var payload_focus_id: String = String(progress_payload.get("focused_node_id", ""))
	if _has_node(payload_focus_id):
		return payload_focus_id

	var next_node_id: String = String(progress_payload.get("next_node_id", ""))
	if _has_node(next_node_id):
		return next_node_id

	for node in nodes:
		if _is_playable_state(String(node.get("state", ""))):
			return String(node.get("node_id", ""))

	return ""


func _get_node_diameter(node: Dictionary, is_focused: bool) -> float:
	var state: String = String(node.get("state", "locked"))
	if state == "next":
		return 166.0 if is_focused else 154.0
	if state == "completed":
		return 128.0 if is_focused else 118.0
	if state == "available":
		return 138.0 if is_focused else 126.0
	return 108.0


func _apply_node_style(button: Button, node: Dictionary, is_focused: bool) -> void:
	var state: String = String(node.get("state", "locked"))
	var background_color := Color(0.89, 0.89, 0.88, 1.0)
	var border_color := Color(0.78, 0.78, 0.76, 1.0)
	var font_color := Color(0.34, 0.34, 0.34, 1.0)

	match state:
		"completed":
			background_color = Color(0.70, 0.84, 0.76, 1.0)
			border_color = Color(0.42, 0.64, 0.54, 1.0)
			font_color = Color(0.17, 0.33, 0.25, 1.0)
		"next":
			background_color = Color(0.95, 0.83, 0.54, 1.0)
			border_color = Color(0.86, 0.61, 0.24, 1.0)
			font_color = Color(0.36, 0.22, 0.05, 1.0)
		"available":
			background_color = Color(0.84, 0.88, 0.92, 1.0)
			border_color = Color(0.57, 0.66, 0.76, 1.0)
			font_color = Color(0.22, 0.28, 0.35, 1.0)
		"locked":
			background_color = Color(0.92, 0.92, 0.91, 1.0)
			border_color = Color(0.80, 0.80, 0.79, 1.0)
			font_color = Color(0.52, 0.52, 0.52, 1.0)

	if is_focused and _is_playable_state(state):
		border_color = border_color.lightened(0.08)

	var normal_style := _build_node_style(button.size.x, background_color, border_color, is_focused)
	var pressed_style := _build_node_style(
		button.size.x,
		background_color.darkened(0.04),
		border_color,
		is_focused
	)
	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", normal_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_stylebox_override("focus", normal_style)
	button.add_theme_color_override("font_color", font_color)
	button.add_theme_color_override("font_hover_color", font_color)
	button.add_theme_color_override("font_pressed_color", font_color)
	button.add_theme_font_size_override("font_size", 34 if state == "next" else 28)
	button.disabled = false


func _build_node_style(
	diameter: float,
	background_color: Color,
	border_color: Color,
	is_focused: bool
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_color = border_color
	style.border_width_left = 4
	style.border_width_top = 4
	style.border_width_right = 4
	style.border_width_bottom = 4
	var radius: int = int(diameter * 0.5)
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_right = radius
	style.corner_radius_bottom_left = radius
	style.shadow_color = Color(0.17, 0.14, 0.10, 0.14)
	style.shadow_size = 14 if is_focused else 8
	style.shadow_offset = Vector2(0, 4)
	return style


func _pulse_node(index: int) -> void:
	var button: Button = node_buttons[index]
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", Vector2(1.06, 1.06), 0.08)
	tween.tween_property(button, "scale", Vector2.ONE, 0.12)


func _build_category_label(node: Dictionary) -> String:
	var category_id: String = String(node.get("primary_category_id", ""))
	if category_id.is_empty():
		return "Ready to play"
	return "%s practice" % category_id.replace("_", " ").capitalize()


func _build_hint_text(state: String) -> String:
	if state == "completed":
		return "Replay this step."
	if state == "available":
		return "You can play this step."
	if state == "next":
		return "This is the next step."
	return locked_hint_default


func _get_node_by_id(node_id: String) -> Dictionary:
	for node in nodes:
		if String(node.get("node_id", "")) == node_id:
			return node
	return {}


func _has_node(node_id: String) -> bool:
	return not _get_node_by_id(node_id).is_empty()


func _resolve_point(area_size: Vector2, factor: Vector2) -> Vector2:
	return Vector2(area_size.x * factor.x, area_size.y * factor.y)


func _is_playable_state(state: String) -> bool:
	return state == "completed" or state == "next" or state == "available"


func _extract_nodes(raw_nodes: Variant) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if typeof(raw_nodes) != TYPE_ARRAY:
		return out

	for raw_node in raw_nodes:
		if typeof(raw_node) != TYPE_DICTIONARY:
			continue
		out.append((raw_node as Dictionary).duplicate(true))
	return out
