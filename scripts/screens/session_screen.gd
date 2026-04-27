extends Control

const ANCHOR_MATCH_SCENE := preload("res://scenes/puzzles/anchor_match_scene.tscn")
const REVERSE_ANCHOR_MATCH_SCENE := preload("res://scenes/puzzles/reverse_anchor_match_scene.tscn")
const PAIR_COMPLETION_SCENE := preload("res://scenes/puzzles/pair_completion_scene.tscn")

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

    var round_def: Dictionary = rounds[round_index].duplicate(true)
    var puzzle_type: String = String(round_def.get("puzzle_type", "anchor_match"))
    var puzzle_scene := _get_puzzle_scene(puzzle_type)
    if puzzle_scene == null:
        push_warning("Unsupported puzzle_type on SessionScreen: %s" % puzzle_type)
        _finish_session()
        return

    current_puzzle = puzzle_scene.instantiate()
    puzzle_host.add_child(current_puzzle)
    current_puzzle.round_completed.connect(_on_round_completed)

    var round_choices: Array = round_def.get("choices", [])
    if consecutive_supported >= 2 and round_choices.size() > 2:
        round_def["choices"] = round_choices.slice(0, 2)
        round_def["choice_count"] = round_def["choices"].size()
    current_puzzle.configure_round(_build_scene_round_def(round_def))
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


func _get_puzzle_scene(puzzle_type: String) -> PackedScene:
    match puzzle_type:
        "anchor_match":
            return ANCHOR_MATCH_SCENE
        "quality_anchor_match":
            return ANCHOR_MATCH_SCENE
        "reverse_anchor_match":
            return REVERSE_ANCHOR_MATCH_SCENE
        "pair_completion":
            return PAIR_COMPLETION_SCENE
        _:
            return null


func _build_scene_round_def(round_def: Dictionary) -> Dictionary:
    var puzzle_type: String = String(round_def.get("puzzle_type", "anchor_match"))
    if puzzle_type != "anchor_match" and puzzle_type != "quality_anchor_match":
        return round_def

    var scene_round := round_def.duplicate(true)
    scene_round["target_picture_asset"] = String(round_def.get("target_asset_path", ""))
    scene_round["correct_symbol_asset"] = String(round_def.get("correct_choice_asset_path", ""))
    scene_round["target_picture_scale"] = float(round_def.get("target_picture_scale", 1.0))

    var legacy_choices: Array[Dictionary] = []
    for choice in round_def.get("choices", []):
        legacy_choices.append({
            "id": String(choice.get("id", "")),
            "symbol_asset": String(choice.get("asset_path", "")),
        })
    scene_round["choices"] = legacy_choices
    return scene_round
