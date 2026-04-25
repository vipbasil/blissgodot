extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

@onready var play_button: Button = %PlayButton
@onready var parent_button: Button = %ParentButton


func _ready() -> void:
    play_button.pressed.connect(_on_play_pressed)
    parent_button.pressed.connect(_on_parent_pressed)


func _on_play_pressed() -> void:
    navigate_requested.emit("main_progress", {
        "completed_session_count": AppState.get_completed_session_count(),
        "next_node_id": "phase_1_anchor_01",
    })


func _on_parent_pressed() -> void:
    navigate_requested.emit("parent_gate", {})
