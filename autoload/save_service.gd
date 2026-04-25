extends Node

const SAVE_PATH := "user://save_v1.json"
const BACKUP_PATH := "user://save_v1.bak"
const TEMP_PATH := "user://save_v1.tmp"


func load_save() -> Dictionary:
    var loaded := _load_json_file(SAVE_PATH)
    if not loaded.is_empty():
        return loaded

    loaded = _load_json_file(BACKUP_PATH)
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


func save_save(payload: Dictionary) -> void:
    var text := JSON.stringify(payload, "\t")
    var temp := FileAccess.open(TEMP_PATH, FileAccess.WRITE)
    if temp == null:
        push_warning("Failed to open temp save file.")
        return
    temp.store_string(text)
    temp.flush()

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.copy_absolute(SAVE_PATH, BACKUP_PATH)

    if FileAccess.file_exists(SAVE_PATH):
        DirAccess.remove_absolute(SAVE_PATH)
    DirAccess.rename_absolute(TEMP_PATH, SAVE_PATH)


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
