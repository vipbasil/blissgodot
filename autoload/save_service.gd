extends Node

const SAVE_V1_PATH := "user://save_v1.json"
const SAVE_V1_BACKUP_PATH := "user://save_v1.bak"
const SAVE_V1_TEMP_PATH := "user://save_v1.tmp"

const SAVE_V2_PATH := "user://save_v2.json"
const SAVE_V2_BACKUP_PATH := "user://save_v2.bak"
const SAVE_V2_TEMP_PATH := "user://save_v2.tmp"


func load_save() -> Dictionary:
    return load_v1_save()


func save_save(payload: Dictionary) -> void:
    save_v1_save(payload)


func load_v1_save() -> Dictionary:
    var loaded := _load_json_file(SAVE_V1_PATH)
    if not loaded.is_empty():
        return loaded

    loaded = _load_json_file(SAVE_V1_BACKUP_PATH)
    if not loaded.is_empty():
        return loaded

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


func save_v1_save(payload: Dictionary) -> void:
    _save_json_file(payload, SAVE_V1_PATH, SAVE_V1_BACKUP_PATH, SAVE_V1_TEMP_PATH)


func load_v2_shell() -> Dictionary:
    var loaded := _load_json_file(SAVE_V2_PATH)
    if not loaded.is_empty():
        return loaded

    loaded = _load_json_file(SAVE_V2_BACKUP_PATH)
    if not loaded.is_empty():
        return loaded

    return {}


func save_v2_shell(payload: Dictionary) -> void:
    _save_json_file(payload, SAVE_V2_PATH, SAVE_V2_BACKUP_PATH, SAVE_V2_TEMP_PATH)


func has_v1_save() -> bool:
    return FileAccess.file_exists(SAVE_V1_PATH) or FileAccess.file_exists(SAVE_V1_BACKUP_PATH)


func has_v2_shell() -> bool:
    return FileAccess.file_exists(SAVE_V2_PATH) or FileAccess.file_exists(SAVE_V2_BACKUP_PATH)


func _load_json_file(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed


func _save_json_file(payload: Dictionary, save_path: String, backup_path: String, temp_path: String) -> void:
    var text := JSON.stringify(payload, "\t")
    var temp := FileAccess.open(temp_path, FileAccess.WRITE)
    if temp == null:
        push_warning("Failed to open temp save file.")
        return
    temp.store_string(text)
    temp.flush()

    if FileAccess.file_exists(save_path):
        DirAccess.copy_absolute(save_path, backup_path)

    if FileAccess.file_exists(save_path):
        DirAccess.remove_absolute(save_path)
    DirAccess.rename_absolute(temp_path, save_path)
