extends Control

const ANCHOR_MATCH_SCENE := preload("res://scenes/puzzles/anchor_match_scene.tscn")

signal navigate_requested(screen_id: String, payload: Dictionary)

@onready var progress_dots = %ProgressDots
@onready var puzzle_host: Control = %PuzzleHost

var node_id := ""
var session_plan: Dictionary = {}
var round_index := 0
var results: Array[Dictionary] = []
var consecutive_supported := 0
var current_puzzle: Node


func initialize(payload: Dictionary) -> void:
    node_id = String(payload.get("node_id", ""))
    session_plan = payload.get("session_plan", {}).duplicate(true)


func _ready() -> void:
    if session_plan.is_empty():
        push_warning("SessionScreen missing session_plan for node: %s" % node_id)
        return

    progress_dots.set_total(int(session_plan.get("total_rounds", 0)))
    _show_round()


func _show_round() -> void:
    var rounds: Array = session_plan.get("rounds", [])
    if round_index >= rounds.size():
        _finish_session()
        return

    progress_dots.set_current(round_index + 1)

    if is_instance_valid(current_puzzle):
        current_puzzle.queue_free()

    current_puzzle = ANCHOR_MATCH_SCENE.instantiate()
    puzzle_host.add_child(current_puzzle)
    current_puzzle.round_completed.connect(_on_round_completed)

    var round_def: Dictionary = rounds[round_index].duplicate(true)
    var round_choices: Array = round_def.get("choices", [])
    if consecutive_supported >= 2 and round_choices.size() > 2:
        round_def["choices"] = round_choices.slice(0, 2)
        round_def["choice_count"] = round_def["choices"].size()
    current_puzzle.configure_round(round_def)
    current_puzzle.begin_round()


func _on_round_completed(result: Dictionary) -> void:
    results.append(result)

    if String(result.get("outcome", "")) == "supported_success":
        consecutive_supported += 1
    else:
        consecutive_supported = 0

    round_index += 1
    _show_round()


func _finish_session() -> void:
    navigate_requested.emit("session_summary", {
        "node_id": node_id,
        "results": results.duplicate(true),
    })
