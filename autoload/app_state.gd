extends Node

const SAVE_PATH := "user://save_v1.json"

var save_data: Dictionary = {}


func _ready() -> void:
    reset_to_defaults()


func reset_to_defaults() -> void:
    save_data = _build_default_save()


func _build_default_save() -> Dictionary:
    return {
        "schema_version": 1,
        "profile": {
            "child_id": "default",
        },
        "progression": {
            "completed_session_count": 0,
            "completed_node_ids": [],
            "last_played_node_id": "",
            "last_completed_node_id": "",
            "concepts": {},
        },
        "parent_progress": {
            "symbols_learned": 0,
            "categories_mastered": 0,
        },
        "settings": {
            "sfx_enabled": true,
        },
    }


func load_from_disk() -> void:
    var loaded := SaveService.load_save()
    save_data = _normalize_loaded_save(loaded)
    _refresh_parent_progress()


func persist() -> void:
    SaveService.save_save(save_data)


func get_completed_session_count() -> int:
    return int(save_data.get("progression", {}).get("completed_session_count", 0))


func get_intro_mode_for_next_session() -> bool:
    return get_completed_session_count() == 0


func get_completed_node_ids() -> Array[String]:
    return _extract_string_array(save_data.get("progression", {}).get("completed_node_ids", []))


func get_last_played_node_id() -> String:
    return String(save_data.get("progression", {}).get("last_played_node_id", ""))


func get_last_completed_node_id() -> String:
    return String(save_data.get("progression", {}).get("last_completed_node_id", ""))


func is_sfx_enabled() -> bool:
    return bool(save_data.get("settings", {}).get("sfx_enabled", true))


func mark_node_started(node_id: String) -> void:
    if node_id.is_empty():
        return

    var progression: Dictionary = save_data.get("progression", {})
    progression["last_played_node_id"] = node_id
    save_data["progression"] = progression
    persist()


func record_completed_node(node_id: String) -> void:
    if node_id.is_empty():
        return

    var progression: Dictionary = save_data.get("progression", {})
    var completed_node_ids: Array[String] = _extract_string_array(progression.get("completed_node_ids", []))
    if not completed_node_ids.has(node_id):
        completed_node_ids.append(node_id)

    progression["completed_node_ids"] = completed_node_ids
    progression["last_completed_node_id"] = node_id
    progression["last_played_node_id"] = node_id
    save_data["progression"] = progression
    persist()


func record_session_results(results: Array[Dictionary]) -> void:
    var progression: Dictionary = save_data["progression"]
    var concept_progress: Dictionary = progression.get("concepts", {})

    progression["completed_session_count"] = int(progression.get("completed_session_count", 0)) + 1

    for result in results:
        var concept_id: String = String(result.get("concept_id", ""))
        if concept_id.is_empty():
            continue

        var entry: Dictionary = concept_progress.get(concept_id, {
            "exposure_count": 0,
            "independent_success_count": 0,
            "supported_success_count": 0,
            "learned": false,
        })
        entry["exposure_count"] = int(entry.get("exposure_count", 0)) + 1

        var outcome: String = String(result.get("outcome", ""))
        if outcome == "independent_success":
            entry["independent_success_count"] = int(entry.get("independent_success_count", 0)) + 1
        elif outcome == "supported_success":
            entry["supported_success_count"] = int(entry.get("supported_success_count", 0)) + 1

        entry["learned"] = (
            int(entry.get("exposure_count", 0)) >= 3
            and int(entry.get("independent_success_count", 0)) >= 2
        )
        concept_progress[concept_id] = entry

    progression["concepts"] = concept_progress
    save_data["progression"] = progression
    _refresh_parent_progress()
    persist()


func get_parent_progress_summary() -> Dictionary:
    return save_data.get("parent_progress", {}).duplicate(true)


func get_concept_progress_snapshot() -> Dictionary:
    return save_data.get("progression", {}).get("concepts", {}).duplicate(true)


func get_category_progress_rows() -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var concept_progress: Dictionary = get_concept_progress_snapshot()
    var completed_sessions := get_completed_session_count()

    for category in ContentDB.get_categories():
        var category_id: String = String(category.get("id", ""))
        var concepts_in_category: Array[Dictionary] = ContentDB.get_released_concepts_by_category(
            category_id,
            completed_sessions
        )
        var learned_count: int = 0

        for concept in concepts_in_category:
            var concept_id: String = String(concept.get("id", ""))
            var progress: Dictionary = concept_progress.get(concept_id, {})
            if bool(progress.get("learned", false)):
                learned_count += 1

        rows.append({
            "id": category_id,
            "display_name": String(category.get("display_name", category_id.capitalize())),
            "learned_count": learned_count,
            "total_count": concepts_in_category.size(),
            "mastered": concepts_in_category.size() > 0 and learned_count == concepts_in_category.size(),
        })

    return rows


func _refresh_parent_progress() -> void:
    var concept_progress: Dictionary = save_data.get("progression", {}).get("concepts", {})
    var completed_sessions := get_completed_session_count()
    var learned_count: int = 0
    for concept in _get_released_concepts(completed_sessions):
        var concept_id: String = String(concept.get("id", ""))
        var concept_entry: Dictionary = concept_progress.get(concept_id, {})
        if bool(concept_entry.get("learned", false)):
            learned_count += 1

    var mastered_categories: int = 0
    for category in ContentDB.get_categories():
        if _is_category_mastered(String(category.get("id", ""))):
            mastered_categories += 1

    save_data["parent_progress"] = {
        "symbols_learned": learned_count,
        "categories_mastered": mastered_categories,
    }


func _is_category_mastered(category_id: String) -> bool:
    if category_id.is_empty():
        return false

    var concept_progress: Dictionary = save_data.get("progression", {}).get("concepts", {})
    var concepts_in_category: Array[Dictionary] = ContentDB.get_released_concepts_by_category(
        category_id,
        get_completed_session_count()
    )
    if concepts_in_category.is_empty():
        return false

    for concept in concepts_in_category:
        var concept_id: String = String(concept.get("id", ""))
        var entry: Dictionary = concept_progress.get(concept_id, {})
        if not bool(entry.get("learned", false)):
            return false
    return true


func _get_released_concepts(completed_sessions: int) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    for category in ContentDB.get_categories():
        var category_id: String = String(category.get("id", ""))
        out.append_array(ContentDB.get_released_concepts_by_category(category_id, completed_sessions))
    return out


func _normalize_loaded_save(loaded: Variant) -> Dictionary:
    var normalized := _build_default_save()
    if typeof(loaded) != TYPE_DICTIONARY:
        return normalized

    var source: Dictionary = loaded
    normalized["schema_version"] = int(source.get("schema_version", normalized["schema_version"]))

    var profile: Dictionary = normalized["profile"]
    if typeof(source.get("profile", null)) == TYPE_DICTIONARY:
        var source_profile: Dictionary = source["profile"]
        profile["child_id"] = String(source_profile.get("child_id", profile["child_id"]))
    normalized["profile"] = profile

    var settings: Dictionary = normalized["settings"]
    if typeof(source.get("settings", null)) == TYPE_DICTIONARY:
        var source_settings: Dictionary = source["settings"]
        settings["sfx_enabled"] = bool(source_settings.get("sfx_enabled", settings["sfx_enabled"]))
    normalized["settings"] = settings

    var progression: Dictionary = normalized["progression"]
    if typeof(source.get("progression", null)) == TYPE_DICTIONARY:
        var source_progression: Dictionary = source["progression"]
        progression["completed_session_count"] = max(
            0,
            int(source_progression.get("completed_session_count", 0))
        )
        progression["completed_node_ids"] = _extract_string_array(
            source_progression.get("completed_node_ids", [])
        )
        progression["last_played_node_id"] = String(source_progression.get("last_played_node_id", ""))
        progression["last_completed_node_id"] = String(source_progression.get("last_completed_node_id", ""))
        progression["concepts"] = _normalize_concept_progress(source_progression.get("concepts", {}))
    normalized["progression"] = progression

    return normalized


func _normalize_concept_progress(raw_concepts: Variant) -> Dictionary:
    var normalized: Dictionary = {}
    if typeof(raw_concepts) != TYPE_DICTIONARY:
        return normalized

    var source_concepts: Dictionary = raw_concepts
    for raw_concept_id in source_concepts.keys():
        var concept_id := String(raw_concept_id)
        if concept_id.is_empty():
            continue

        var raw_entry: Variant = source_concepts[raw_concept_id]
        if typeof(raw_entry) != TYPE_DICTIONARY:
            continue

        var source_entry: Dictionary = raw_entry
        normalized[concept_id] = {
            "exposure_count": max(0, int(source_entry.get("exposure_count", 0))),
            "independent_success_count": max(0, int(source_entry.get("independent_success_count", 0))),
            "supported_success_count": max(0, int(source_entry.get("supported_success_count", 0))),
            "learned": bool(source_entry.get("learned", false)),
        }

    return normalized


func _extract_string_array(raw_values: Variant) -> Array[String]:
    var out: Array[String] = []
    if typeof(raw_values) != TYPE_ARRAY:
        return out

    for value in raw_values:
        var normalized := String(value)
        if normalized.is_empty():
            continue
        if out.has(normalized):
            continue
        out.append(normalized)
    return out
