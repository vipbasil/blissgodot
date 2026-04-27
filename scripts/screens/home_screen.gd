extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

@onready var play_button: Button = %PlayButton
@onready var parent_button: Button = %ParentButton

var _direct_touch_handled := false


func _ready() -> void:
    play_button.pressed.connect(_on_play_pressed)
    parent_button.pressed.connect(_on_parent_pressed)


func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        var touch_event := event as InputEventScreenTouch
        if touch_event.pressed:
            _direct_touch_handled = _handle_direct_touch(touch_event.position)
            if _direct_touch_handled:
                get_viewport().set_input_as_handled()
        else:
            _direct_touch_handled = false
    elif event is InputEventMouseButton:
        var mouse_event := event as InputEventMouseButton
        if mouse_event.button_index != MOUSE_BUTTON_LEFT:
            return
        if mouse_event.pressed:
            _direct_touch_handled = _handle_direct_touch(mouse_event.global_position)
            if _direct_touch_handled:
                get_viewport().set_input_as_handled()
        else:
            _direct_touch_handled = false


func _on_play_pressed() -> void:
    navigate_requested.emit("main_progress", {
        "completed_session_count": AppState.get_completed_session_count(),
        "next_node_id": "phase_1_anchor_01",
    })


func _on_parent_pressed() -> void:
    navigate_requested.emit("parent_gate", {})


func _handle_direct_touch(global_position: Vector2) -> bool:
    if play_button.get_global_rect().has_point(global_position):
        _on_play_pressed()
        return true
    if parent_button.get_global_rect().has_point(global_position):
        _on_parent_pressed()
        return true
    return false
