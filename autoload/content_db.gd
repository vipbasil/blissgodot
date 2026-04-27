extends Node

const CONCEPTS_PATH := "res://data/curriculum/concepts.json"
const COMPOSITIONS_PATH := "res://data/curriculum/compositions.json"
const CATEGORIES_PATH := "res://data/curriculum/categories.json"
const SYMBOLS_PATH := "res://data/curriculum/symbols.json"
const TRACKS_PATH := "res://data/curriculum/tracks.json"
const EXEMPLARS_PATH := "res://data/curriculum/exemplars.json"
const PUZZLE_TEMPLATES_PATH := "res://data/curriculum/puzzle_templates.json"
const APP_CONFIG_PATH := "res://data/config/app_config.json"
const PROGRESSION_NODES_PATH := "res://data/progression/progression_nodes.json"

var concepts_by_id: Dictionary = {}
var compositions_by_id: Dictionary = {}
var categories: Array[Dictionary] = []
var symbols_by_id: Dictionary = {}
var tracks_by_id: Dictionary = {}
var tracks: Array[Dictionary] = []
var exemplars_by_id: Dictionary = {}
var exemplars_by_symbol_id: Dictionary = {}
var puzzle_templates_by_id: Dictionary = {}
var app_config: Dictionary = {}
var progression_nodes_by_id: Dictionary = {}
var progression_nodes: Array[Dictionary] = []


func _ready() -> void:
    load_content()


func load_content() -> void:
    concepts_by_id.clear()
    compositions_by_id.clear()
    categories.clear()
    symbols_by_id.clear()
    tracks_by_id.clear()
    tracks.clear()
    exemplars_by_id.clear()
    exemplars_by_symbol_id.clear()
    puzzle_templates_by_id.clear()
    progression_nodes_by_id.clear()
    progression_nodes.clear()

    var concepts_doc: Dictionary = _load_json(CONCEPTS_PATH)
    for concept in concepts_doc.get("concepts", []):
        var row: Dictionary = concept
        concepts_by_id[String(row.get("id", ""))] = row

    var compositions_doc: Dictionary = _load_json(COMPOSITIONS_PATH)
    for composition in compositions_doc.get("compositions", []):
        var row: Dictionary = composition
        compositions_by_id[String(row.get("id", ""))] = row

    var categories_doc: Dictionary = _load_json(CATEGORIES_PATH)
    for category in categories_doc.get("categories", []):
        categories.append(category)

    var symbols_doc: Dictionary = _load_json(SYMBOLS_PATH)
    for symbol in symbols_doc.get("symbols", []):
        var symbol_row: Dictionary = symbol
        var symbol_id: String = String(symbol_row.get("id", ""))
        if symbol_id.is_empty():
            continue
        symbols_by_id[symbol_id] = symbol_row

    var tracks_doc: Dictionary = _load_json(TRACKS_PATH)
    for track in tracks_doc.get("tracks", []):
        var track_row: Dictionary = track
        var track_id: String = String(track_row.get("id", ""))
        if track_id.is_empty():
            continue
        tracks_by_id[track_id] = track_row
        tracks.append(track_row)
    tracks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
        return int(a.get("sort_order", 0)) < int(b.get("sort_order", 0))
    )

    var exemplars_doc: Dictionary = _load_json(EXEMPLARS_PATH)
    for exemplar in exemplars_doc.get("exemplars", []):
        var exemplar_row: Dictionary = exemplar
        var exemplar_id: String = String(exemplar_row.get("id", ""))
        if exemplar_id.is_empty():
            continue
        exemplars_by_id[exemplar_id] = exemplar_row

        var symbol_id: String = String(exemplar_row.get("symbol_id", ""))
        if symbol_id.is_empty():
            continue
        if not exemplars_by_symbol_id.has(symbol_id):
            exemplars_by_symbol_id[symbol_id] = []
        var exemplar_rows: Array = exemplars_by_symbol_id[symbol_id]
        exemplar_rows.append(exemplar_row)
        exemplars_by_symbol_id[symbol_id] = exemplar_rows

    var puzzle_templates_doc: Dictionary = _load_json(PUZZLE_TEMPLATES_PATH)
    for puzzle_template in puzzle_templates_doc.get("puzzle_templates", []):
        var template_row: Dictionary = puzzle_template
        var template_id: String = String(template_row.get("id", ""))
        if template_id.is_empty():
            continue
        puzzle_templates_by_id[template_id] = template_row

    var progression_nodes_doc: Dictionary = _load_json(PROGRESSION_NODES_PATH)
    for node_def in progression_nodes_doc.get("nodes", []):
        var row: Dictionary = _build_progression_node_runtime_row(node_def)
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
    var concept: Dictionary = concepts_by_id.get(concept_id, {}).duplicate(true)
    return _merge_symbol_metadata(concept_id, concept)


func get_categories() -> Array[Dictionary]:
    return categories.duplicate(true)


func get_symbol(symbol_id: String) -> Dictionary:
    return symbols_by_id.get(symbol_id, {}).duplicate(true)


func get_composition(composition_id: String) -> Dictionary:
    return compositions_by_id.get(composition_id, {}).duplicate(true)


func get_track(track_id: String) -> Dictionary:
    return tracks_by_id.get(track_id, {}).duplicate(true)


func get_tracks() -> Array[Dictionary]:
    return tracks.duplicate(true)


func get_exemplar(exemplar_id: String) -> Dictionary:
    return exemplars_by_id.get(exemplar_id, {}).duplicate(true)


func get_puzzle_template(puzzle_template_id: String) -> Dictionary:
    return puzzle_templates_by_id.get(puzzle_template_id, {}).duplicate(true)


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
    var puzzle_template_id := "anchor_phase_1_intro"
    var puzzle_template := get_puzzle_template(puzzle_template_id)

    var rounds: Array[Dictionary] = []
    var candidate_ids := _get_released_candidate_ids(prior_completed_sessions)
    for index in round_concepts.size():
        var concept_id: String = round_concepts[index]
        var choice_count: int = 3
        if use_intro and prior_completed_sessions == 0 and index < 2:
            choice_count = 2
        rounds.append(_decorate_round_def_with_v2_metadata(
            _build_anchor_round_def(concept_id, choice_count, candidate_ids),
            puzzle_template_id,
            puzzle_template,
            []
        ))

    return {
        "session_id": "first_playable",
        "session_template_id": puzzle_template_id,
        "puzzle_template_id": puzzle_template_id,
        "puzzle_template": puzzle_template.duplicate(true),
        "total_rounds": rounds.size(),
        "rounds": rounds,
    }


func build_session_plan_for_node(node_id: String, prior_completed_sessions: int) -> Dictionary:
    var node_def := get_progression_node(node_id)
    if node_def.is_empty():
        return {}

    var puzzle_template_id: String = _resolve_puzzle_template_id(node_def)
    var puzzle_template: Dictionary = get_puzzle_template(puzzle_template_id)
    var session_ids: Array[String] = _extract_string_array(node_def.get("session_content_ids", []))
    if session_ids.is_empty():
        return {}

    var repeat_ids: Array[String] = _extract_string_array(node_def.get("repeat_ids", []))
    var review_ids: Array[String] = _extract_string_array(node_def.get("review_ids", []))
    var round_target: int = max(
        1,
        int(node_def.get("session_round_target", app_config.get("session_round_target", 8)))
    )
    var puzzle_type: String = String(node_def.get("puzzle_type", "anchor_match"))
    var candidate_ids: Array[String] = _get_released_candidate_ids(prior_completed_sessions)
    var composition_candidate_ids: Array[String] = _get_released_composition_ids(prior_completed_sessions)
    var filler_ids := composition_candidate_ids if _puzzle_type_uses_composition_content(puzzle_type) else candidate_ids
    var round_concepts := _build_node_round_concepts(
        session_ids,
        review_ids,
        repeat_ids,
        round_target,
        prior_completed_sessions,
        filler_ids
    )

    var rounds: Array[Dictionary] = []
    var use_intro_rules := bool(node_def.get("use_intro_rules", false))
    var intro_round_count: int = max(0, int(node_def.get("intro_round_count", 0)))
    var default_choice_count: int = max(2, int(node_def.get("default_choice_count", 3)))
    var node_track_ids: Array[String] = _extract_string_array(node_def.get("track_ids", []))

    for index in round_concepts.size():
        var concept_id: String = round_concepts[index]
        var choice_count: int = default_choice_count
        if use_intro_rules and prior_completed_sessions == 0 and index < intro_round_count:
            choice_count = min(choice_count, 2)
        var round_def := _build_round_def_for_puzzle_type(
            puzzle_type,
            concept_id,
            choice_count,
            candidate_ids,
            composition_candidate_ids,
            index
        )
        rounds.append(_decorate_round_def_with_v2_metadata(
            round_def,
            puzzle_template_id,
            puzzle_template,
            node_track_ids
        ))

    return {
        "session_id": node_id,
        "node_id": node_id,
        "session_template_id": String(node_def.get("session_template_id", "")),
        "puzzle_template_id": puzzle_template_id,
        "puzzle_template": puzzle_template.duplicate(true),
        "track_id": String(node_def.get("track_id", "")),
        "track_ids": node_track_ids.duplicate(),
        "total_rounds": rounds.size(),
        "rounds": rounds,
    }


func _build_round_def_for_puzzle_type(
    puzzle_type: String,
    concept_id: String,
    choice_count: int,
    candidate_ids: Array[String],
    composition_candidate_ids: Array[String] = [],
    round_index: int = 0
) -> Dictionary:
    if puzzle_type == "reverse_anchor_match":
        return _build_reverse_anchor_round_def(concept_id, choice_count, candidate_ids)
    if puzzle_type == "quality_anchor_match":
        return _build_quality_anchor_round_def(concept_id, choice_count, composition_candidate_ids)
    if puzzle_type == "pair_completion":
        return _build_pair_completion_round_def(concept_id, choice_count, composition_candidate_ids, round_index)
    return _build_anchor_round_def(concept_id, choice_count, candidate_ids)


func _build_anchor_round_def(concept_id: String, choice_count: int, candidate_ids: Array[String]) -> Dictionary:
    var correct_concept: Dictionary = get_concept(concept_id)
    var target_exemplar: Dictionary = _get_preferred_exemplar_for_symbol(concept_id, "anchor_match")
    var distractor_ids: Array[String] = []
    for candidate in candidate_ids:
        if candidate == concept_id:
            continue
        distractor_ids.append(candidate)

    var choices: Array[Dictionary] = []
    choices.append({
        "id": concept_id,
        "asset_path": String(correct_concept.get("symbol_asset", "")),
    })

    var distractor_count: int = max(choice_count - 1, 0)
    for i in min(distractor_count, distractor_ids.size()):
        var distractor_id: String = distractor_ids[i]
        var distractor_concept: Dictionary = get_concept(distractor_id)
        choices.append({
            "id": distractor_id,
            "asset_path": String(distractor_concept.get("symbol_asset", "")),
        })

    return {
        "puzzle_type": "anchor_match",
        "concept_id": concept_id,
        "target_symbol_id": concept_id,
        "target_exemplar_id": String(target_exemplar.get("id", "")),
        "target_asset_path": _resolve_exemplar_asset_path(
            target_exemplar,
            String(correct_concept.get("picture_asset", ""))
        ),
        "target_content_kind": "picture",
        "correct_choice_asset_path": String(correct_concept.get("symbol_asset", "")),
        "choice_content_kind": "symbol",
        "choice_count": choices.size(),
        "correct_choice_id": concept_id,
        "choices": choices,
        "max_wrong_attempts_before_support": 2,
    }


func _build_reverse_anchor_round_def(concept_id: String, choice_count: int, candidate_ids: Array[String]) -> Dictionary:
    var correct_concept: Dictionary = get_concept(concept_id)
    var correct_choice_exemplar: Dictionary = _get_preferred_exemplar_for_symbol(
        concept_id,
        "reverse_anchor_match"
    )
    var distractor_ids: Array[String] = []
    for candidate in candidate_ids:
        if candidate == concept_id:
            continue
        distractor_ids.append(candidate)

    var choices: Array[Dictionary] = []
    choices.append({
        "id": concept_id,
        "asset_path": _resolve_exemplar_asset_path(
            correct_choice_exemplar,
            String(correct_concept.get("picture_asset", ""))
        ),
        "exemplar_id": String(correct_choice_exemplar.get("id", "")),
    })

    var distractor_count: int = max(choice_count - 1, 0)
    for i in min(distractor_count, distractor_ids.size()):
        var distractor_id: String = distractor_ids[i]
        var distractor_concept: Dictionary = get_concept(distractor_id)
        var distractor_exemplar: Dictionary = _get_preferred_exemplar_for_symbol(
            distractor_id,
            "reverse_anchor_match"
        )
        choices.append({
            "id": distractor_id,
            "asset_path": _resolve_exemplar_asset_path(
                distractor_exemplar,
                String(distractor_concept.get("picture_asset", ""))
            ),
            "exemplar_id": String(distractor_exemplar.get("id", "")),
        })

    return {
        "puzzle_type": "reverse_anchor_match",
        "concept_id": concept_id,
        "target_symbol_id": concept_id,
        "target_asset_path": String(correct_concept.get("symbol_asset", "")),
        "target_content_kind": "symbol",
        "correct_choice_exemplar_id": String(correct_choice_exemplar.get("id", "")),
        "correct_choice_asset_path": _resolve_exemplar_asset_path(
            correct_choice_exemplar,
            String(correct_concept.get("picture_asset", ""))
        ),
        "choice_content_kind": "picture",
        "choice_count": choices.size(),
        "correct_choice_id": concept_id,
        "choices": choices,
        "max_wrong_attempts_before_support": 2,
    }


func _build_quality_anchor_round_def(
    composition_id: String,
    choice_count: int,
    composition_candidate_ids: Array[String]
) -> Dictionary:
    var composition: Dictionary = get_composition(composition_id)
    if composition.is_empty():
        return {}

    var modifier_id: String = String(composition.get("modifier_id", ""))
    var modifier_symbol: Dictionary = get_symbol(modifier_id)
    var result_exemplar_id: String = String(composition.get("result_exemplar_id", ""))
    var quality_prompt_exemplar_id: String = String(
        composition.get("quality_prompt_exemplar_id", result_exemplar_id)
    )
    var quality_prompt_exemplar: Dictionary = get_exemplar(quality_prompt_exemplar_id)
    var modifier_asset: String = String(composition.get("modifier_symbol_asset", ""))
    if modifier_asset.is_empty():
        modifier_asset = String(modifier_symbol.get("bliss_symbol_asset", ""))

    return {
        "puzzle_type": "quality_anchor_match",
        "composition_id": composition_id,
        "concept_id": modifier_id,
        "target_symbol_id": modifier_id,
        "target_exemplar_id": quality_prompt_exemplar_id,
        "target_asset_path": _resolve_exemplar_asset_path(
            quality_prompt_exemplar,
            String(composition.get("result_picture_asset", ""))
        ),
        "target_picture_scale": float(
            quality_prompt_exemplar.get("visual_scale", composition.get("result_picture_scale", 0.72))
        ),
        "target_content_kind": "picture",
        "correct_choice_asset_path": modifier_asset,
        "choice_content_kind": "symbol",
        "choice_count": min(choice_count, 2),
        "correct_choice_id": modifier_id,
        "choices": _build_modifier_symbol_choices(
            modifier_id,
            min(choice_count, 2),
            composition_candidate_ids
        ),
        "max_wrong_attempts_before_support": 1,
    }


func _build_pair_completion_round_def(
    composition_id: String,
    choice_count: int,
    composition_candidate_ids: Array[String],
    round_index: int
) -> Dictionary:
    var composition: Dictionary = get_composition(composition_id)
    if composition.is_empty():
        return {}

    var result_exemplar_id: String = String(composition.get("result_exemplar_id", ""))
    var result_exemplar: Dictionary = get_exemplar(result_exemplar_id)
    var base_concept_id: String = String(composition.get("base_concept_id", ""))
    var base_concept: Dictionary = get_concept(base_concept_id)
    var modifier_id: String = String(composition.get("modifier_id", ""))
    var modifier_asset: String = String(composition.get("modifier_symbol_asset", ""))
    var is_modifier_missing: bool = (round_index % 2) == 0
    var formula_slots: Array[Dictionary] = []
    var choices: Array[Dictionary] = []

    if is_modifier_missing:
        formula_slots = [
            {
                "id": "",
                "asset_path": "",
                "content_kind": "symbol",
                "is_missing": true,
            },
            {
                "id": base_concept_id,
                "asset_path": String(base_concept.get("symbol_asset", "")),
                "content_kind": "symbol",
                "is_missing": false,
            },
        ]

        var modifier_choices: Array[Dictionary] = _build_modifier_symbol_choices(
            modifier_id,
            choice_count,
            composition_candidate_ids
        )
        choices.append_array(modifier_choices)
    else:
        formula_slots = [
            {
                "id": modifier_id,
                "asset_path": modifier_asset,
                "content_kind": "symbol",
                "is_missing": false,
            },
            {
                "id": "",
                "asset_path": "",
                "content_kind": "symbol",
                "is_missing": true,
            },
        ]

        var noun_choices: Array[Dictionary] = _build_noun_symbol_choices(
            base_concept_id,
            choice_count,
            composition_candidate_ids
        )
        choices.append_array(noun_choices)

    return {
        "puzzle_type": "pair_completion",
        "composition_id": composition_id,
        "concept_id": base_concept_id,
        "target_symbol_id": base_concept_id,
        "target_exemplar_id": result_exemplar_id,
        "result_asset_path": _resolve_exemplar_asset_path(
            result_exemplar,
            String(composition.get("result_picture_asset", ""))
        ),
        "result_picture_scale": float(composition.get("result_picture_scale", 0.72)),
        "choice_content_kind": "symbol",
        "formula_slots": formula_slots,
        "correct_choice_id": modifier_id if is_modifier_missing else base_concept_id,
        "correct_choice_asset_path": modifier_asset if is_modifier_missing else String(base_concept.get("symbol_asset", "")),
        "choice_count": choices.size(),
        "choices": choices,
        "max_wrong_attempts_before_support": 2,
    }


func _build_modifier_symbol_choices(
    correct_modifier_id: String,
    choice_count: int,
    composition_candidate_ids: Array[String]
) -> Array[Dictionary]:
    var unique_modifiers: Dictionary = {}
    for composition_id in composition_candidate_ids:
        var composition: Dictionary = get_composition(composition_id)
        var modifier_id: String = String(composition.get("modifier_id", ""))
        if modifier_id.is_empty() or unique_modifiers.has(modifier_id):
            continue
        unique_modifiers[modifier_id] = String(composition.get("modifier_symbol_asset", ""))

    var choices: Array[Dictionary] = []
    if unique_modifiers.has(correct_modifier_id):
        choices.append({
            "id": correct_modifier_id,
            "asset_path": String(unique_modifiers[correct_modifier_id]),
        })

    for modifier_id in unique_modifiers.keys():
        var normalized_id := String(modifier_id)
        if normalized_id == correct_modifier_id:
            continue
        if choices.size() >= max(choice_count, 2):
            break
        choices.append({
            "id": normalized_id,
            "asset_path": String(unique_modifiers[modifier_id]),
        })
    return choices


func _build_noun_symbol_choices(
    correct_base_concept_id: String,
    choice_count: int,
    composition_candidate_ids: Array[String]
) -> Array[Dictionary]:
    var unique_base_ids: Dictionary = {}
    for composition_id in composition_candidate_ids:
        var composition: Dictionary = get_composition(composition_id)
        var base_concept_id: String = String(composition.get("base_concept_id", ""))
        if base_concept_id.is_empty() or unique_base_ids.has(base_concept_id):
            continue
        var base_concept: Dictionary = get_concept(base_concept_id)
        unique_base_ids[base_concept_id] = String(base_concept.get("symbol_asset", ""))

    var choices: Array[Dictionary] = []
    if unique_base_ids.has(correct_base_concept_id):
        choices.append({
            "id": correct_base_concept_id,
            "asset_path": String(unique_base_ids[correct_base_concept_id]),
        })

    for base_concept_id in unique_base_ids.keys():
        var normalized_id := String(base_concept_id)
        if normalized_id == correct_base_concept_id:
            continue
        if choices.size() >= max(choice_count, 2):
            break
        choices.append({
            "id": normalized_id,
            "asset_path": String(unique_base_ids[base_concept_id]),
        })
    return choices


func _decorate_round_def_with_v2_metadata(
    round_def: Dictionary,
    puzzle_template_id: String,
    puzzle_template: Dictionary,
    node_track_ids: Array[String]
) -> Dictionary:
    if round_def.is_empty():
        return {}

    var decorated := round_def.duplicate(true)
    decorated["puzzle_template_id"] = puzzle_template_id
    if not puzzle_template.is_empty():
        decorated["puzzle_template"] = puzzle_template.duplicate(true)
    if not node_track_ids.is_empty():
        decorated["track_ids"] = node_track_ids.duplicate()
    return decorated


func _build_progression_node_runtime_row(node_def: Dictionary) -> Dictionary:
    var row: Dictionary = node_def.duplicate(true)
    var puzzle_template_id: String = _resolve_puzzle_template_id(row)
    if not puzzle_template_id.is_empty():
        row["puzzle_template_id"] = puzzle_template_id
        var puzzle_template: Dictionary = get_puzzle_template(puzzle_template_id)
        if not puzzle_template.is_empty():
            row["puzzle_template"] = puzzle_template

    var session_ids: Array[String] = _extract_string_array(row.get("session_content_ids", []))
    var review_ids: Array[String] = _extract_string_array(row.get("review_ids", []))
    var repeat_ids: Array[String] = _extract_string_array(row.get("repeat_ids", []))
    var puzzle_type: String = String(row.get("puzzle_type", "anchor_match"))

    if puzzle_type == "pair_completion":
        row["focus_composition_ids"] = session_ids.duplicate()
        row["repeat_composition_ids"] = repeat_ids.duplicate()
        row["focus_symbol_ids"] = _collect_member_symbol_ids_from_compositions(session_ids)
        row["review_symbol_ids"] = _collect_member_symbol_ids_from_compositions(review_ids)
        row["repeat_symbol_ids"] = _collect_member_symbol_ids_from_compositions(repeat_ids)
    elif puzzle_type == "quality_anchor_match":
        row["focus_composition_ids"] = session_ids.duplicate()
        row["repeat_composition_ids"] = repeat_ids.duplicate()
        row["focus_symbol_ids"] = _collect_modifier_symbol_ids_from_compositions(session_ids)
        row["review_symbol_ids"] = _collect_modifier_symbol_ids_from_compositions(review_ids)
        row["repeat_symbol_ids"] = _collect_modifier_symbol_ids_from_compositions(repeat_ids)
    else:
        row["focus_symbol_ids"] = session_ids.duplicate()
        row["review_symbol_ids"] = review_ids.duplicate()
        row["repeat_symbol_ids"] = repeat_ids.duplicate()

    var explicit_track_ids: Array[String] = _extract_string_array(row.get("track_ids", []))
    var track_ids: Array[String] = _collect_track_ids_for_node_content(
        session_ids,
        review_ids,
        repeat_ids,
        puzzle_type
    )
    if not explicit_track_ids.is_empty():
        row["track_ids"] = explicit_track_ids.duplicate()
    elif not track_ids.is_empty():
        row["track_ids"] = track_ids.duplicate()

    var explicit_track_id: String = String(row.get("track_id", ""))
    var resolved_track_ids: Array[String] = _extract_string_array(row.get("track_ids", []))
    if explicit_track_id.is_empty() and resolved_track_ids.size() == 1:
        row["track_id"] = resolved_track_ids[0]

    var allowed_exemplar_group_ids: Array[String] = _collect_allowed_exemplar_group_ids(
        session_ids,
        review_ids,
        repeat_ids,
        puzzle_type
    )
    if not allowed_exemplar_group_ids.is_empty():
        row["allowed_exemplar_group_ids"] = allowed_exemplar_group_ids

    return row


func _resolve_puzzle_template_id(row: Dictionary) -> String:
    var puzzle_template_id: String = String(row.get("puzzle_template_id", ""))
    if not puzzle_template_id.is_empty():
        return puzzle_template_id
    return String(row.get("session_template_id", ""))


func _merge_symbol_metadata(content_id: String, row: Dictionary) -> Dictionary:
    var merged: Dictionary = row.duplicate(true)
    var symbol: Dictionary = get_symbol(content_id)
    if symbol.is_empty():
        return merged

    for key in symbol.keys():
        if not merged.has(key):
            merged[key] = symbol[key]
    if String(merged.get("symbol_asset", "")).is_empty():
        merged["symbol_asset"] = String(symbol.get("bliss_symbol_asset", ""))
    return merged


func _get_preferred_exemplar_for_symbol(symbol_id: String, puzzle_type: String) -> Dictionary:
    var exemplar_rows: Array = exemplars_by_symbol_id.get(symbol_id, [])
    var fallback: Dictionary = {}

    for raw_row in exemplar_rows:
        if typeof(raw_row) != TYPE_DICTIONARY:
            continue
        var row: Dictionary = raw_row
        if not bool(row.get("enabled", true)):
            continue
        if fallback.is_empty():
            fallback = row
        var supported_puzzle_types: Array[String] = _extract_string_array(
            row.get("supports_puzzle_types", [])
        )
        if not supported_puzzle_types.has(puzzle_type):
            continue
        if String(row.get("salience_level", "")) == "primary":
            return row.duplicate(true)
        if fallback.is_empty():
            fallback = row

    return fallback.duplicate(true)


func _resolve_exemplar_asset_path(exemplar: Dictionary, fallback_asset_path: String) -> String:
    var exemplar_asset_path: String = String(exemplar.get("asset_path", ""))
    if exemplar_asset_path.is_empty():
        return fallback_asset_path
    return exemplar_asset_path


func _collect_track_ids_for_node_content(
    session_ids: Array[String],
    review_ids: Array[String],
    repeat_ids: Array[String],
    puzzle_type: String
) -> Array[String]:
    var out: Array[String] = []
    var seen: Dictionary = {}
    var all_ids: Array[String] = []
    all_ids.append_array(session_ids)
    all_ids.append_array(review_ids)
    all_ids.append_array(repeat_ids)

    for content_id in all_ids:
        var source_row: Dictionary = {}
        if _puzzle_type_uses_composition_content(puzzle_type):
            source_row = get_composition(content_id)
        else:
            source_row = get_symbol(content_id)
        for track_id in _extract_string_array(source_row.get("default_track_ids", [])):
            if seen.has(track_id):
                continue
            seen[track_id] = true
            out.append(track_id)
    return out


func _collect_member_symbol_ids_from_compositions(composition_ids: Array[String]) -> Array[String]:
    var out: Array[String] = []
    var seen: Dictionary = {}
    for composition_id in composition_ids:
        var composition: Dictionary = get_composition(composition_id)
        for symbol_id in _extract_string_array(composition.get("member_symbol_ids", [])):
            if seen.has(symbol_id):
                continue
            seen[symbol_id] = true
            out.append(symbol_id)
    return out


func _collect_modifier_symbol_ids_from_compositions(composition_ids: Array[String]) -> Array[String]:
    var out: Array[String] = []
    var seen: Dictionary = {}
    for composition_id in composition_ids:
        var composition: Dictionary = get_composition(composition_id)
        var modifier_id: String = String(composition.get("modifier_id", ""))
        if modifier_id.is_empty() or seen.has(modifier_id):
            continue
        seen[modifier_id] = true
        out.append(modifier_id)
    return out


func _collect_allowed_exemplar_group_ids(
    session_ids: Array[String],
    review_ids: Array[String],
    repeat_ids: Array[String],
    puzzle_type: String
) -> Array[String]:
    var out: Array[String] = []
    var seen: Dictionary = {}
    var all_ids: Array[String] = []
    all_ids.append_array(session_ids)
    all_ids.append_array(review_ids)
    all_ids.append_array(repeat_ids)

    if _puzzle_type_uses_composition_content(puzzle_type):
        for composition_id in all_ids:
            var composition: Dictionary = get_composition(composition_id)
            var exemplar_id: String = String(composition.get("result_exemplar_id", ""))
            if puzzle_type == "quality_anchor_match":
                exemplar_id = String(composition.get("quality_prompt_exemplar_id", exemplar_id))
            var exemplar: Dictionary = get_exemplar(exemplar_id)
            var variant_group_id: String = String(exemplar.get("variant_group_id", ""))
            if variant_group_id.is_empty() or seen.has(variant_group_id):
                continue
            seen[variant_group_id] = true
            out.append(variant_group_id)
        return out

    for symbol_id in all_ids:
        var exemplar: Dictionary = _get_preferred_exemplar_for_symbol(symbol_id, puzzle_type)
        var variant_group_id: String = String(exemplar.get("variant_group_id", ""))
        if variant_group_id.is_empty() or seen.has(variant_group_id):
            continue
        seen[variant_group_id] = true
        out.append(variant_group_id)
    return out


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
    prior_completed_sessions: int,
    filler_ids: Array[String] = []
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
        var fallback_ids: Array[String] = filler_ids
        if fallback_ids.is_empty():
            fallback_ids = _get_released_candidate_ids(prior_completed_sessions)
        for concept_id in fallback_ids:
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


func _get_released_composition_ids(completed_sessions: int) -> Array[String]:
    var max_phase: int = get_unlocked_release_phase(completed_sessions)
    var out: Array[String] = []
    var seen: Dictionary = {}
    for composition_id in compositions_by_id.keys():
        var composition: Dictionary = compositions_by_id[composition_id]
        if int(composition.get("release_phase", 999)) > max_phase:
            continue
        if not bool(composition.get("enabled", true)):
            continue

        var normalized_id := String(composition_id)
        if seen.has(normalized_id):
            continue
        seen[normalized_id] = true
        out.append(normalized_id)
    out.sort()
    return out


func _puzzle_type_uses_composition_content(puzzle_type: String) -> bool:
    return puzzle_type == "pair_completion" or puzzle_type == "quality_anchor_match"


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
