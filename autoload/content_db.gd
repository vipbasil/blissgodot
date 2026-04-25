extends Node

const CONCEPTS_PATH := "res://data/curriculum/concepts.json"
const CATEGORIES_PATH := "res://data/curriculum/categories.json"
const APP_CONFIG_PATH := "res://data/config/app_config.json"
const PROGRESSION_NODES_PATH := "res://data/progression/progression_nodes.json"

var concepts_by_id: Dictionary = {}
var categories: Array[Dictionary] = []
var app_config: Dictionary = {}
var progression_nodes_by_id: Dictionary = {}
var progression_nodes: Array[Dictionary] = []


func _ready() -> void:
    load_content()


func load_content() -> void:
    concepts_by_id.clear()
    categories.clear()
    progression_nodes_by_id.clear()
    progression_nodes.clear()

    var concepts_doc: Dictionary = _load_json(CONCEPTS_PATH)
    for concept in concepts_doc.get("concepts", []):
        var row: Dictionary = concept
        concepts_by_id[String(row.get("id", ""))] = row

    var categories_doc: Dictionary = _load_json(CATEGORIES_PATH)
    for category in categories_doc.get("categories", []):
        categories.append(category)

    var progression_nodes_doc: Dictionary = _load_json(PROGRESSION_NODES_PATH)
    for node_def in progression_nodes_doc.get("nodes", []):
        var row: Dictionary = node_def
        var node_id: String = String(row.get("node_id", ""))
        if node_id.is_empty():
            continue
        progression_nodes_by_id[node_id] = row
        progression_nodes.append(row)
    progression_nodes.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return int(a.get("sort_order", 0)) < int(b.get("sort_order", 0))
    )

    app_config = _load_json(APP_CONFIG_PATH)


func get_concept(concept_id: String) -> Dictionary:
    return concepts_by_id.get(concept_id, {}).duplicate(true)


func get_categories() -> Array[Dictionary]:
    return categories.duplicate(true)


func get_progression_node(node_id: String) -> Dictionary:
    return progression_nodes_by_id.get(node_id, {}).duplicate(true)


func get_progression_nodes() -> Array[Dictionary]:
    return progression_nodes.duplicate(true)


func get_released_progression_nodes(completed_sessions: int) -> Array[Dictionary]:
    var max_phase := get_unlocked_release_phase(completed_sessions)
    var out: Array[Dictionary] = []
    for node_def in progression_nodes:
        if int(node_def.get("release_phase", 999)) > max_phase:
            continue
        out.append(node_def.duplicate(true))
    return out


func get_concepts_by_category(category_id: String) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    for concept in concepts_by_id.values():
        if String(concept.get("category_id", "")) == category_id:
            out.append(concept.duplicate(true))
    return out


func get_released_concepts_by_category(category_id: String, completed_sessions: int) -> Array[Dictionary]:
    var max_phase := get_unlocked_release_phase(completed_sessions)
    var out: Array[Dictionary] = []
    for concept in concepts_by_id.values():
        if String(concept.get("category_id", "")) != category_id:
            continue
        if int(concept.get("release_phase", 999)) > max_phase:
            continue
        if not bool(concept.get("enabled", true)):
            continue
        out.append(concept.duplicate(true))
    return out


func get_unlocked_release_phase(completed_sessions: int) -> int:
    var phase := 1
    for row in app_config.get("phase_unlocks", []):
        var unlock_phase := int(row.get("release_phase", phase))
        var min_sessions := int(row.get("min_completed_sessions", 0))
        if completed_sessions >= min_sessions:
            phase = max(phase, unlock_phase)
    return phase


func build_first_playable_session_plan(use_intro: bool, prior_completed_sessions: int) -> Dictionary:
    var active_phase := get_unlocked_release_phase(prior_completed_sessions)
    var round_concepts := _build_phase_round_concepts(active_phase, prior_completed_sessions)

    var rounds: Array[Dictionary] = []
    var candidate_ids := _get_released_candidate_ids(prior_completed_sessions)
    for index in round_concepts.size():
        var concept_id: String = round_concepts[index]
        var choice_count: int = 3
        if use_intro and prior_completed_sessions == 0 and index < 2:
            choice_count = 2
        rounds.append(_build_round_def(concept_id, choice_count, candidate_ids))

    return {
        "session_id": "first_playable",
        "total_rounds": rounds.size(),
        "rounds": rounds,
    }


func build_session_plan_for_node(node_id: String, prior_completed_sessions: int) -> Dictionary:
    var node_def := get_progression_node(node_id)
    if node_def.is_empty():
        return {}

    var session_ids: Array[String] = _extract_string_array(node_def.get("session_content_ids", []))
    if session_ids.is_empty():
        return {}

    var repeat_ids: Array[String] = _extract_string_array(node_def.get("repeat_ids", []))
    var review_ids: Array[String] = _extract_string_array(node_def.get("review_ids", []))
    var round_target: int = max(
        1,
        int(node_def.get("session_round_target", app_config.get("session_round_target", 8)))
    )
    var round_concepts := _build_node_round_concepts(
        session_ids,
        review_ids,
        repeat_ids,
        round_target,
        prior_completed_sessions
    )

    var candidate_ids: Array[String] = _get_released_candidate_ids(prior_completed_sessions)
    var rounds: Array[Dictionary] = []
    var use_intro_rules := bool(node_def.get("use_intro_rules", false))
    var intro_round_count: int = max(0, int(node_def.get("intro_round_count", 0)))
    var default_choice_count: int = max(2, int(node_def.get("default_choice_count", 3)))

    for index in round_concepts.size():
        var concept_id: String = round_concepts[index]
        var choice_count: int = default_choice_count
        if use_intro_rules and prior_completed_sessions == 0 and index < intro_round_count:
            choice_count = min(choice_count, 2)
        rounds.append(_build_round_def(concept_id, choice_count, candidate_ids))

    return {
        "session_id": node_id,
        "node_id": node_id,
        "session_template_id": String(node_def.get("session_template_id", "")),
        "total_rounds": rounds.size(),
        "rounds": rounds,
    }


func _build_round_def(concept_id: String, choice_count: int, candidate_ids: Array[String]) -> Dictionary:
    var correct_concept: Dictionary = get_concept(concept_id)
    var distractor_ids: Array[String] = []
    for candidate in candidate_ids:
        if candidate == concept_id:
            continue
        distractor_ids.append(candidate)

    var choices: Array[Dictionary] = []
    choices.append({
        "id": concept_id,
        "symbol_asset": String(correct_concept.get("symbol_asset", "")),
    })

    var distractor_count: int = max(choice_count - 1, 0)
    for i in min(distractor_count, distractor_ids.size()):
        var distractor_id: String = distractor_ids[i]
        var distractor_concept: Dictionary = get_concept(distractor_id)
        choices.append({
            "id": distractor_id,
            "symbol_asset": String(distractor_concept.get("symbol_asset", "")),
        })

    return {
        "puzzle_type": "anchor_match",
        "concept_id": concept_id,
        "target_picture_asset": String(correct_concept.get("picture_asset", "")),
        "correct_symbol_asset": String(correct_concept.get("symbol_asset", "")),
        "choice_count": choices.size(),
        "correct_choice_id": concept_id,
        "choices": choices,
        "max_wrong_attempts_before_support": 2,
    }


func _build_phase_round_concepts(active_phase: int, prior_completed_sessions: int) -> Array[String]:
    var target_round_count: int = max(1, int(app_config.get("session_round_target", 8)))
    var session_ids: Array[String] = _get_phase_id_list(active_phase, "session_ids")
    var repeat_ids: Array[String] = _get_phase_id_list(active_phase, "repeat_ids")
    var review_ids: Array[String] = _get_phase_id_list(active_phase, "review_ids")

    var reserved_slots: int = min(target_round_count, repeat_ids.size() + review_ids.size())
    var primary_slots: int = max(target_round_count - reserved_slots, 0)
    var round_concepts: Array[String] = []

    if primary_slots > 0:
        round_concepts.append_array(_take_rotating_slice(
            session_ids,
            primary_slots,
            _get_phase_rotation_offset(active_phase, prior_completed_sessions)
        ))

    round_concepts.append_array(review_ids)
    round_concepts.append_array(repeat_ids)

    if round_concepts.size() < target_round_count:
        var filler_ids: Array[String] = _get_released_candidate_ids(prior_completed_sessions)
        for concept_id in filler_ids:
            if round_concepts.size() >= target_round_count:
                break
            if round_concepts.has(concept_id):
                continue
            round_concepts.append(concept_id)

    return round_concepts


func _build_node_round_concepts(
    session_ids: Array[String],
    review_ids: Array[String],
    repeat_ids: Array[String],
    target_round_count: int,
    prior_completed_sessions: int
) -> Array[String]:
    var reserved_slots: int = min(target_round_count, review_ids.size() + repeat_ids.size())
    var primary_slots: int = max(target_round_count - reserved_slots, 0)
    var round_concepts: Array[String] = []

    if primary_slots > 0:
        var rotation_offset: int = 0
        if not session_ids.is_empty():
            rotation_offset = prior_completed_sessions % session_ids.size()
        round_concepts.append_array(_take_rotating_slice(session_ids, primary_slots, rotation_offset))

    round_concepts.append_array(review_ids)
    round_concepts.append_array(repeat_ids)

    if round_concepts.size() < target_round_count:
        var filler_ids: Array[String] = _get_released_candidate_ids(prior_completed_sessions)
        for concept_id in filler_ids:
            if round_concepts.size() >= target_round_count:
                break
            if round_concepts.has(concept_id):
                continue
            round_concepts.append(concept_id)

    return round_concepts


func _get_phase_id_list(phase: int, suffix: String) -> Array[String]:
    var key: String = "phase_%d_%s" % [phase, suffix]
    var out: Array[String] = []
    for value in app_config.get(key, []):
        var concept_id := String(value)
        if concept_id.is_empty():
            continue
        out.append(concept_id)
    return out


func _extract_string_array(raw_values: Variant) -> Array[String]:
    var out: Array[String] = []
    if typeof(raw_values) != TYPE_ARRAY:
        return out

    for value in raw_values:
        var normalized := String(value)
        if normalized.is_empty():
            continue
        out.append(normalized)
    return out


func _get_phase_rotation_offset(active_phase: int, prior_completed_sessions: int) -> int:
    var session_ids: Array[String] = _get_phase_id_list(active_phase, "session_ids")
    if session_ids.is_empty():
        return 0

    var phase_start_sessions: int = _get_phase_min_completed_sessions(active_phase)
    var sessions_since_unlock: int = max(prior_completed_sessions - phase_start_sessions, 0)
    return (sessions_since_unlock * 2) % session_ids.size()


func _get_phase_min_completed_sessions(phase: int) -> int:
    for row in app_config.get("phase_unlocks", []):
        if int(row.get("release_phase", 0)) == phase:
            return int(row.get("min_completed_sessions", 0))
    return 0


func _take_rotating_slice(source: Array[String], requested_count: int, offset: int) -> Array[String]:
    var out: Array[String] = []
    if source.is_empty() or requested_count <= 0:
        return out

    var count: int = min(requested_count, source.size())
    var start: int = posmod(offset, source.size())
    for index in count:
        out.append(source[(start + index) % source.size()])
    return out


func _get_released_candidate_ids(completed_sessions: int) -> Array[String]:
    var max_phase: int = get_unlocked_release_phase(completed_sessions)
    var out: Array[String] = []
    var seen: Dictionary = {}
    for concept_id in concepts_by_id.keys():
        var concept: Dictionary = concepts_by_id[concept_id]
        if int(concept.get("release_phase", 999)) > max_phase:
            continue
        if not bool(concept.get("enabled", true)):
            continue

        var normalized_id := String(concept_id)
        if seen.has(normalized_id):
            continue
        seen[normalized_id] = true
        out.append(normalized_id)
    out.sort()
    return out


func _load_json(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}

    var text := file.get_as_text()
    var parsed: Variant = JSON.parse_string(text)
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed
