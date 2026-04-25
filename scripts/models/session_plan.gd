class_name SessionPlan
extends RefCounted

var session_id: String
var total_rounds: int
var rounds: Array[PuzzleRoundDef]


static func from_dict(data: Dictionary) -> SessionPlan:
    var plan := SessionPlan.new()
    plan.session_id = String(data.get("session_id", ""))
    plan.total_rounds = int(data.get("total_rounds", 0))
    plan.rounds = []
    for entry in data.get("rounds", []):
        plan.rounds.append(PuzzleRoundDef.from_dict(entry))
    return plan
