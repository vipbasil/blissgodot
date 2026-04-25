extends Control

signal navigate_requested(screen_id: String, payload: Dictionary)

const HOLD_TO_UNLOCK_SECONDS := 1.35

@onready var prompt_label: Label = %PromptLabel
@onready var hint_label: Label = %HintLabel
@onready var continue_button: Button = %ContinueButton
@onready var hold_progress: ProgressBar = %HoldProgress
@onready var cancel_button: Button = %CancelButton

var hold_active := false
var hold_elapsed := 0.0
var gate_opened := false


func _ready() -> void:
    continue_button.button_down.connect(_on_continue_button_down)
    continue_button.button_up.connect(_on_continue_button_up)
    cancel_button.pressed.connect(_on_cancel_pressed)
    _reset_hold_state()


func _process(delta: float) -> void:
    if not hold_active or gate_opened:
        return

    hold_elapsed += delta
    hold_progress.value = min((hold_elapsed / HOLD_TO_UNLOCK_SECONDS) * 100.0, 100.0)
    if hold_elapsed >= HOLD_TO_UNLOCK_SECONDS:
        _open_parent_progress()


func _input(event: InputEvent) -> void:
    if not hold_active or gate_opened:
        return

    if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        _reset_hold_state()
    elif event is InputEventScreenTouch and not event.pressed:
        _reset_hold_state()


func _on_continue_button_down() -> void:
    if gate_opened:
        return

    hold_active = true
    hold_elapsed = 0.0
    hold_progress.visible = true
    hold_progress.value = 0.0
    prompt_label.text = "Hold to open parent area"
    hint_label.text = "Keep holding..."


func _on_continue_button_up() -> void:
    if gate_opened:
        return
    _reset_hold_state()


func _open_parent_progress() -> void:
    gate_opened = true
    hold_active = false
    hold_progress.value = 100.0
    prompt_label.text = "Opening parent area"
    hint_label.text = ""
    navigate_requested.emit("parent_progress", {})


func _on_cancel_pressed() -> void:
    navigate_requested.emit("home", {})


func _reset_hold_state() -> void:
    hold_active = false
    hold_elapsed = 0.0
    hold_progress.visible = false
    hold_progress.value = 0.0
    prompt_label.text = "Parent Area"
    hint_label.text = "Hold the button to continue"
