class_name PuzzleRoundDef
extends RefCounted

var puzzle_type: String
var concept_id: String
var composition_id: String
var target_asset_path: String
var target_content_kind: String
var result_asset_path: String
var result_picture_scale: float
var correct_choice_asset_path: String
var choice_content_kind: String
var correct_choice_id: String
var choice_count: int
var max_wrong_attempts_before_support: int
var choices: Array[Dictionary]
var formula_slots: Array[Dictionary]


static func from_dict(data: Dictionary) -> PuzzleRoundDef:
    var round := PuzzleRoundDef.new()
    round.puzzle_type = String(data.get("puzzle_type", "anchor_match"))
    round.concept_id = String(data.get("concept_id", ""))
    round.composition_id = String(data.get("composition_id", ""))
    round.target_asset_path = String(data.get("target_asset_path", ""))
    round.target_content_kind = String(data.get("target_content_kind", "picture"))
    round.result_asset_path = String(data.get("result_asset_path", ""))
    round.result_picture_scale = float(data.get("result_picture_scale", 0.72))
    round.correct_choice_asset_path = String(data.get("correct_choice_asset_path", ""))
    round.choice_content_kind = String(data.get("choice_content_kind", "symbol"))
    round.correct_choice_id = String(data.get("correct_choice_id", ""))
    round.choice_count = int(data.get("choice_count", 0))
    round.max_wrong_attempts_before_support = int(data.get("max_wrong_attempts_before_support", 2))
    round.choices = []
    for entry in data.get("choices", []):
        round.choices.append(entry.duplicate(true))
    round.formula_slots = []
    for slot in data.get("formula_slots", []):
        round.formula_slots.append(slot.duplicate(true))
    return round
