class_name PuzzleRoundDef
extends RefCounted

var puzzle_type: String
var concept_id: String
var target_picture_asset: String
var correct_symbol_asset: String
var correct_choice_id: String
var choice_count: int
var max_wrong_attempts_before_support: int
var choices: Array[Dictionary]


static func from_dict(data: Dictionary) -> PuzzleRoundDef:
    var round := PuzzleRoundDef.new()
    round.puzzle_type = String(data.get("puzzle_type", "anchor_match"))
    round.concept_id = String(data.get("concept_id", ""))
    round.target_picture_asset = String(data.get("target_picture_asset", ""))
    round.correct_symbol_asset = String(data.get("correct_symbol_asset", ""))
    round.correct_choice_id = String(data.get("correct_choice_id", ""))
    round.choice_count = int(data.get("choice_count", 0))
    round.max_wrong_attempts_before_support = int(data.get("max_wrong_attempts_before_support", 2))
    round.choices = []
    for entry in data.get("choices", []):
        round.choices.append(entry.duplicate(true))
    return round
