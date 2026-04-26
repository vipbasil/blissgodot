extends Control

signal wrong_answer(attempt_count: int, removed_choice_id: StringName)
signal support_state_changed(is_supported: bool, remaining_choice_count: int)
signal round_completed(result: Dictionary)

const CHOICE_CARD_SCENE := preload("res://scenes/components/choice_card.tscn")
const MOUSE_POINTER_ID := ChoiceCard.MOUSE_POINTER_ID
const NO_POINTER_ID := -999

@onready var result_texture: TextureRect = %ResultTexture
@onready var left_slot: PanelContainer = %LeftSlot
@onready var right_slot: PanelContainer = %RightSlot
@onready var left_slot_anchor: Control = %LeftSlotAnchor
@onready var right_slot_anchor: Control = %RightSlotAnchor
@onready var option_tray = %OptionTray
@onready var calm_feedback = %CalmFeedback
@onready var drag_layer: Control = %DragLayer

var round_def: Dictionary = {}
var attempt_count := 0
var in_supported_state := false
var choice_cards: Dictionary = {}
var removed_choice_ids: Array[String] = []
var input_locked := true
var active_drag_source_card = null
var active_drag_proxy = null
var settled_drag_proxy = null
var active_drag_choice_id := ""
var active_drag_home_global_position := Vector2.ZERO
var active_drag_pointer_offset := Vector2.ZERO
var active_drag_pointer_id := NO_POINTER_ID
var drag_transition_in_progress := false
var static_slot_card: Control
var missing_slot_index := 0


func configure_round(new_round_def: Dictionary) -> void:
	round_def = new_round_def


func begin_round() -> void:
	if round_def.is_empty():
		return

	_clear_drag_state(true)
	_render_result()
	_render_formula()
	option_tray.clear_choices()
	choice_cards.clear()
	attempt_count = 0
	in_supported_state = false
	removed_choice_ids.clear()
	input_locked = false
	calm_feedback.hide_feedback()
	_set_missing_slot_highlight(false)

	for choice in round_def.get("choices", []):
		var card = CHOICE_CARD_SCENE.instantiate()
		var choice_id: String = String(choice.get("id", ""))
		option_tray.add_choice(card)
		card.set_choice_data(
			choice_id,
			String(choice.get("asset_path", "")),
			String(round_def.get("choice_content_kind", "symbol"))
		)
		card.drag_pressed.connect(_on_choice_drag_pressed)
		choice_cards[choice_id] = card


func _input(event: InputEvent) -> void:
	if active_drag_proxy == null or drag_transition_in_progress:
		return

	if event is InputEventMouseMotion:
		if active_drag_pointer_id == MOUSE_POINTER_ID:
			_update_active_drag_position((event as InputEventMouseMotion).global_position)
	elif event is InputEventScreenDrag:
		var drag_event := event as InputEventScreenDrag
		if drag_event.index == active_drag_pointer_id:
			_update_active_drag_position(drag_event.position)
	elif event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if active_drag_pointer_id == MOUSE_POINTER_ID and mouse_event.button_index == MOUSE_BUTTON_LEFT and not mouse_event.pressed:
			_release_active_drag(mouse_event.global_position)
	elif event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		if touch_event.index == active_drag_pointer_id and not touch_event.pressed:
			_release_active_drag(touch_event.position)


func _on_choice_drag_pressed(card: Variant, pointer_position: Vector2, pointer_id: int) -> void:
	if input_locked or active_drag_proxy != null:
		return

	var choice_id: String = card.get_choice_id()
	if choice_id.is_empty():
		return

	active_drag_source_card = card
	active_drag_choice_id = choice_id
	active_drag_home_global_position = card.get_global_rect().position
	active_drag_pointer_offset = pointer_position - active_drag_home_global_position
	active_drag_pointer_id = pointer_id

	active_drag_proxy = card.build_drag_proxy(card.get_global_rect().size)
	drag_layer.add_child(active_drag_proxy)
	active_drag_proxy.top_level = true
	active_drag_proxy.global_position = active_drag_home_global_position
	active_drag_source_card.set_drag_source_hidden(true)
	_set_missing_slot_highlight(true)
	_update_active_drag_position(pointer_position)


func _release_active_drag(pointer_position: Vector2) -> void:
	if active_drag_proxy == null:
		return

	_set_missing_slot_highlight(false)

	if not _missing_slot_accepts_global_drop(pointer_position):
		_return_active_drag_to_source(false)
		return

	_handle_drop_on_missing_slot(active_drag_choice_id)


func _update_active_drag_position(pointer_position: Vector2) -> void:
	if active_drag_proxy == null:
		return
	active_drag_proxy.global_position = pointer_position - active_drag_pointer_offset


func _handle_drop_on_missing_slot(choice_id: String) -> void:
	if active_drag_proxy == null:
		return

	var card = choice_cards.get(choice_id)
	if card == null:
		_return_active_drag_to_source(false)
		return

	if choice_id == String(round_def.get("correct_choice_id", "")):
		_complete_round(choice_id)
		return

	_return_active_drag_to_source(true)


func _process_wrong_answer(choice_id: String) -> void:
	attempt_count += 1
	var removed_id: String = _remove_one_distractor(choice_id)
	wrong_answer.emit(attempt_count, StringName(removed_id))

	if _remaining_distractor_count() == 0:
		in_supported_state = true
		support_state_changed.emit(true, _remaining_choice_count())


func _remove_one_distractor(dropped_choice_id: String) -> String:
	if not dropped_choice_id.is_empty() and dropped_choice_id != String(round_def.get("correct_choice_id", "")):
		var dropped_card = choice_cards.get(dropped_choice_id)
		if dropped_card != null and not removed_choice_ids.has(dropped_choice_id):
			removed_choice_ids.append(dropped_choice_id)
			dropped_card.disable_and_hide()
			return dropped_choice_id

	for choice in round_def.get("choices", []):
		var choice_id := String(choice.get("id", ""))
		if choice_id == String(round_def.get("correct_choice_id", "")):
			continue
		if removed_choice_ids.has(choice_id):
			continue
		removed_choice_ids.append(choice_id)
		var card = choice_cards.get(choice_id)
		if card != null:
			card.disable_and_hide()
		return choice_id
	return ""


func _remaining_distractor_count() -> int:
	var count := 0
	for choice in round_def.get("choices", []):
		var choice_id := String(choice.get("id", ""))
		if choice_id == String(round_def.get("correct_choice_id", "")):
			continue
		if not removed_choice_ids.has(choice_id):
			count += 1
	return count


func _remaining_choice_count() -> int:
	var count := 0
	for choice in round_def.get("choices", []):
		var choice_id := String(choice.get("id", ""))
		if not removed_choice_ids.has(choice_id):
			count += 1
	return count


func _complete_round(choice_id: String) -> void:
	input_locked = true
	await _settle_active_drag_on_missing_slot(choice_id)

	calm_feedback.show_success()
	SfxPlayer.play_success()

	var outcome := "independent_success"
	if in_supported_state:
		outcome = "supported_success"

	await get_tree().create_timer(0.45).timeout

	round_completed.emit({
		"concept_id": String(round_def.get("concept_id", "")),
		"composition_id": String(round_def.get("composition_id", "")),
		"outcome": outcome,
		"wrong_attempt_count": attempt_count,
		"shown_choice_count": int(round_def.get("choice_count", 0)),
		"ended_choice_count": _remaining_choice_count(),
	})


func _return_active_drag_to_source(register_wrong_answer: bool) -> void:
	if active_drag_proxy == null:
		return

	input_locked = true
	drag_transition_in_progress = true
	_set_missing_slot_highlight(false)

	var source_card: Variant = active_drag_source_card
	var choice_id := active_drag_choice_id
	var proxy: Variant = active_drag_proxy
	var home_position: Vector2 = active_drag_home_global_position
	active_drag_pointer_id = NO_POINTER_ID

	var tween := create_tween()
	tween.tween_property(proxy, "global_position", home_position, 0.16)
	await tween.finished

	if is_instance_valid(proxy):
		proxy.queue_free()
	if is_instance_valid(source_card):
		source_card.set_drag_source_hidden(false)

	active_drag_proxy = null
	active_drag_source_card = null
	active_drag_choice_id = ""
	active_drag_home_global_position = Vector2.ZERO
	active_drag_pointer_offset = Vector2.ZERO
	drag_transition_in_progress = false
	input_locked = false

	if register_wrong_answer:
		_process_wrong_answer(choice_id)


func _settle_active_drag_on_missing_slot(choice_id: String) -> void:
	if active_drag_proxy == null:
		return

	drag_transition_in_progress = true
	var source_card: Variant = active_drag_source_card
	var proxy: Variant = active_drag_proxy
	var settle_position: Vector2 = _get_missing_slot_settle_global_position(proxy.size)

	active_drag_proxy = null
	active_drag_source_card = null
	active_drag_choice_id = ""
	active_drag_home_global_position = Vector2.ZERO
	active_drag_pointer_offset = Vector2.ZERO
	active_drag_pointer_id = NO_POINTER_ID
	settled_drag_proxy = proxy

	proxy.set_slotted()
	var tween := create_tween()
	tween.tween_property(proxy, "global_position", settle_position, 0.18)
	await tween.finished

	if is_instance_valid(source_card):
		source_card.visible = false
	if is_instance_valid(proxy):
		proxy.global_position = settle_position
	drag_transition_in_progress = false


func _clear_drag_state(remove_proxy: bool) -> void:
	if remove_proxy and is_instance_valid(active_drag_proxy):
		active_drag_proxy.queue_free()
	if remove_proxy and is_instance_valid(settled_drag_proxy):
		settled_drag_proxy.queue_free()
	if is_instance_valid(active_drag_source_card):
		active_drag_source_card.set_drag_source_hidden(false)
	if is_instance_valid(static_slot_card):
		static_slot_card.queue_free()

	active_drag_proxy = null
	active_drag_source_card = null
	settled_drag_proxy = null
	static_slot_card = null
	active_drag_choice_id = ""
	active_drag_home_global_position = Vector2.ZERO
	active_drag_pointer_offset = Vector2.ZERO
	active_drag_pointer_id = NO_POINTER_ID
	drag_transition_in_progress = false


func _render_result() -> void:
	var asset_path: String = String(round_def.get("result_asset_path", ""))
	var scale_factor: float = float(round_def.get("result_picture_scale", 0.72))
	var texture: Texture2D = null
	if not asset_path.is_empty() and ResourceLoader.exists(asset_path):
		texture = load(asset_path) as Texture2D
	result_texture.texture = texture
	result_texture.custom_minimum_size = Vector2(260, 260) * scale_factor


func _render_formula() -> void:
	var slots: Array = round_def.get("formula_slots", [])
	var left_slot_def: Dictionary = slots[0] if slots.size() > 0 else {}
	var right_slot_def: Dictionary = slots[1] if slots.size() > 1 else {}

	missing_slot_index = 0 if bool(left_slot_def.get("is_missing", false)) else 1
	_render_static_formula_slot(left_slot_def, left_slot_anchor)
	_render_static_formula_slot(right_slot_def, right_slot_anchor)
	_set_missing_slot_highlight(false)


func _render_static_formula_slot(slot_def: Dictionary, anchor: Control) -> void:
	if bool(slot_def.get("is_missing", false)):
		return

	var card = CHOICE_CARD_SCENE.instantiate()
	anchor.add_child(card)
	card.set_choice_data(
		String(slot_def.get("id", "")),
		String(slot_def.get("asset_path", "")),
		String(slot_def.get("content_kind", "symbol"))
	)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.anchors_preset = Control.PRESET_FULL_RECT
	card.offset_left = 0
	card.offset_top = 0
	card.offset_right = 0
	card.offset_bottom = 0
	static_slot_card = card


func _missing_slot_accepts_global_drop(global_position: Vector2) -> bool:
	return _get_missing_slot_panel().get_global_rect().has_point(global_position)


func _get_missing_slot_panel() -> PanelContainer:
	return left_slot if missing_slot_index == 0 else right_slot


func _get_missing_slot_anchor() -> Control:
	return left_slot_anchor if missing_slot_index == 0 else right_slot_anchor


func _get_missing_slot_settle_global_position(card_size: Vector2) -> Vector2:
	var anchor_rect := _get_missing_slot_anchor().get_global_rect()
	return anchor_rect.position + ((anchor_rect.size - card_size) * 0.5)


func _set_missing_slot_highlight(is_ready: bool) -> void:
	var target_slot := _get_missing_slot_panel()
	target_slot.modulate = Color(0.98, 0.98, 1.0, 1.0) if is_ready else Color(1, 1, 1, 1)
