extends Node

const SAVE_V2_SCHEMA_VERSION := 2
const LEARNING_STORE_SCHEMA_VERSION := 1
const LEARNING_STORE_PATH := "user://bliss_v2.sqlite"
const SQLITE_CLASS_NAME := "SQLite"
const SQLITE_EXTENSION_PATH := "res://addons/godot-sqlite/gdsqlite.gdextension"

const SYMBOLS_PATH := "res://data/curriculum/symbols.json"
const PROGRESSION_NODES_PATH := "res://data/progression/progression_nodes.json"

const LEGACY_IMPORT_STATUS_COMPLETED := "legacy_import_completed"
const LEGACY_IMPORT_STATUS_FAILED := "legacy_import_failed"
const LEGACY_IMPORT_STATUS_DIRTY := "legacy_bridge_dirty_needs_reimport"
const LEGACY_IMPORT_STATUS_PENDING := "runtime_store_ready_pending_import"
const LEGACY_IMPORT_MIGRATION_ID_PREFIX := "save_v1_to_v2_seed"
const LIVE_RUNTIME_BRIDGE_STATUS := "runtime_store_live_with_legacy_bridge"
const SUPPORT_BAND_RANKS := {
    "low_support": 0,
    "medium_support": 1,
    "high_support": 2,
}
const LEGACY_SEEDED_TABLES := [
    "learner_profile",
    "node_progress",
    "symbol_mastery",
    "migration_log",
]
const LEGACY_UNSEEDED_TABLES := [
    "session_run",
    "round_result",
    "symbol_puzzle_mastery",
    "composition_mastery",
    "track_mastery",
    "reinforcement_queue",
]

const SCHEMA_STATEMENTS := [
    """
    CREATE TABLE IF NOT EXISTS learner_profile (
        learner_id TEXT PRIMARY KEY,
        created_at TEXT,
        display_name TEXT,
        active INTEGER
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS node_progress (
        learner_id TEXT NOT NULL,
        node_id TEXT NOT NULL,
        status TEXT NOT NULL,
        first_started_at TEXT,
        last_started_at TEXT,
        completed_at TEXT,
        play_count INTEGER NOT NULL DEFAULT 0,
        best_support_band TEXT,
        PRIMARY KEY (learner_id, node_id)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS session_run (
        session_run_id TEXT PRIMARY KEY,
        learner_id TEXT NOT NULL,
        node_id TEXT,
        track_id TEXT,
        puzzle_type TEXT,
        puzzle_template_id TEXT,
        started_at TEXT,
        completed_at TEXT,
        round_count INTEGER NOT NULL DEFAULT 0,
        independent_round_count INTEGER NOT NULL DEFAULT 0,
        supported_round_count INTEGER NOT NULL DEFAULT 0,
        star_count INTEGER NOT NULL DEFAULT 0
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS round_result (
        round_result_id TEXT PRIMARY KEY,
        session_run_id TEXT NOT NULL,
        learner_id TEXT NOT NULL,
        node_id TEXT,
        track_id TEXT,
        puzzle_type TEXT,
        puzzle_template_id TEXT,
        target_symbol_id TEXT,
        target_exemplar_id TEXT,
        composition_id TEXT,
        prompt_role TEXT,
        correct_choice_symbol_id TEXT,
        wrong_attempt_count INTEGER NOT NULL DEFAULT 0,
        support_step_count INTEGER NOT NULL DEFAULT 0,
        outcome TEXT,
        response_time_ms INTEGER NOT NULL DEFAULT 0,
        occurred_at TEXT
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS symbol_puzzle_mastery (
        learner_id TEXT NOT NULL,
        symbol_id TEXT NOT NULL,
        puzzle_type TEXT NOT NULL,
        exposure_count INTEGER NOT NULL DEFAULT 0,
        independent_success_count INTEGER NOT NULL DEFAULT 0,
        supported_success_count INTEGER NOT NULL DEFAULT 0,
        distinct_exemplar_count INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        mastery_state TEXT NOT NULL DEFAULT 'new',
        next_due_at TEXT,
        PRIMARY KEY (learner_id, symbol_id, puzzle_type)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS symbol_mastery (
        learner_id TEXT NOT NULL,
        symbol_id TEXT NOT NULL,
        lexical_role TEXT,
        exposure_count INTEGER NOT NULL DEFAULT 0,
        independent_success_count INTEGER NOT NULL DEFAULT 0,
        supported_success_count INTEGER NOT NULL DEFAULT 0,
        stable_puzzle_count INTEGER NOT NULL DEFAULT 0,
        distinct_exemplar_count INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        mastery_state TEXT NOT NULL DEFAULT 'new',
        PRIMARY KEY (learner_id, symbol_id)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS composition_mastery (
        learner_id TEXT NOT NULL,
        composition_id TEXT NOT NULL,
        puzzle_type TEXT NOT NULL,
        exposure_count INTEGER NOT NULL DEFAULT 0,
        independent_success_count INTEGER NOT NULL DEFAULT 0,
        supported_success_count INTEGER NOT NULL DEFAULT 0,
        last_seen_at TEXT,
        mastery_state TEXT NOT NULL DEFAULT 'new',
        next_due_at TEXT,
        PRIMARY KEY (learner_id, composition_id, puzzle_type)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS track_mastery (
        learner_id TEXT NOT NULL,
        track_id TEXT NOT NULL,
        current_stage_label TEXT,
        introduced_symbol_count INTEGER NOT NULL DEFAULT 0,
        stable_symbol_count INTEGER NOT NULL DEFAULT 0,
        stable_composition_count INTEGER NOT NULL DEFAULT 0,
        last_played_at TEXT,
        gate_state TEXT NOT NULL DEFAULT 'locked',
        PRIMARY KEY (learner_id, track_id)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS reinforcement_queue (
        learner_id TEXT NOT NULL,
        item_type TEXT NOT NULL,
        item_id TEXT NOT NULL,
        preferred_puzzle_type TEXT NOT NULL,
        reason TEXT,
        priority_score REAL NOT NULL DEFAULT 0,
        due_at TEXT,
        last_served_at TEXT,
        resolved_at TEXT,
        PRIMARY KEY (learner_id, item_type, item_id, preferred_puzzle_type)
    );
    """,
    """
    CREATE TABLE IF NOT EXISTS migration_log (
        migration_id TEXT PRIMARY KEY,
        source_schema_version INTEGER NOT NULL,
        target_schema_version INTEGER NOT NULL,
        migrated_at TEXT,
        status TEXT NOT NULL,
        notes TEXT
    );
    """
]

var shell_data: Dictionary = {}
var runtime_status: Dictionary = {}
var _runtime_db: Object = null
var _sqlite_extension_resource: Resource = null
var _initialized := false


func _ready() -> void:
    _reset_state()


func initialize() -> void:
    var legacy_save: Dictionary = {}
    var has_legacy_save := SaveService.has_v1_save()
    if has_legacy_save:
        legacy_save = SaveService.load_v1_save()

    shell_data = _normalize_shell(SaveService.load_v2_shell())
    runtime_status = _open_runtime_store()

    var import_result: Dictionary = {}
    if has_legacy_save:
        _apply_legacy_profile_and_settings(legacy_save)
        if is_runtime_store_available():
            import_result = _import_legacy_save(legacy_save)

    _refresh_shell_metadata(has_legacy_save, legacy_save, import_result)
    SaveService.save_v2_shell(shell_data)
    _initialized = true


func is_initialized() -> bool:
    return _initialized


func is_runtime_store_available() -> bool:
    return bool(runtime_status.get("available", false))


func get_runtime_status() -> Dictionary:
    return runtime_status.duplicate(true)


func get_shell_snapshot() -> Dictionary:
    return shell_data.duplicate(true)


func build_legacy_bridge_seed() -> Dictionary:
    var seed := _build_default_legacy_projection()
    seed["profile"] = shell_data.get("profile", {}).duplicate(true)
    seed["settings"] = shell_data.get("settings", {}).duplicate(true)
    return seed


func load_runtime_projection() -> Dictionary:
    if SaveService.has_v1_save():
        return SaveService.load_v1_save()
    return build_legacy_bridge_seed()


func record_session_summary(summary_payload: Dictionary) -> Dictionary:
    if not _initialized:
        initialize()

    if not is_runtime_store_available() or _runtime_db == null:
        return {
            "written": false,
            "reason": String(runtime_status.get("reason", "sqlite_runtime_unavailable")),
        }

    var normalized := _normalize_session_summary_payload(summary_payload)
    if normalized.is_empty():
        return {
            "written": false,
            "reason": "invalid_session_summary_payload",
        }

    if not _execute_sql("BEGIN TRANSACTION;"):
        return {
            "written": false,
            "reason": _get_runtime_db_error(),
        }

    if not _upsert_session_run_row(normalized):
        _rollback_transaction()
        return {
            "written": false,
            "reason": _get_runtime_db_error(),
        }

    if not _replace_round_result_rows(normalized):
        _rollback_transaction()
        return {
            "written": false,
            "reason": _get_runtime_db_error(),
        }

    if not _upsert_node_progress_row(normalized):
        _rollback_transaction()
        return {
            "written": false,
            "reason": _get_runtime_db_error(),
        }

    if not _execute_sql("COMMIT;"):
        _rollback_transaction()
        return {
            "written": false,
            "reason": _get_runtime_db_error(),
        }

    _mark_runtime_store_live_with_legacy_bridge()
    SaveService.save_v2_shell(shell_data)
    return {
        "written": true,
        "session_run_id": String(normalized.get("session_run_id", "")),
        "round_count": int(normalized.get("round_count", 0)),
    }


func sync_legacy_bridge(legacy_save: Dictionary) -> void:
    if not _initialized:
        initialize()

    _apply_legacy_profile_and_settings(legacy_save)

    var migration: Dictionary = shell_data.get("migration", {})
    var source_fingerprint := _build_legacy_source_fingerprint(legacy_save)
    migration["legacy_runtime_bridge"] = true
    migration["source_path"] = SaveService.SAVE_V1_PATH
    migration["source_schema_version"] = 1
    migration["runtime_store_available"] = is_runtime_store_available()
    migration["learning_store_created"] = bool(runtime_status.get("file_exists", false))
    migration["legacy_completed_session_count"] = int(
        legacy_save.get("progression", {}).get("completed_session_count", 0)
    )
    migration["last_legacy_sync_unix"] = int(Time.get_unix_time_from_system())
    migration["source_fingerprint"] = source_fingerprint

    if is_runtime_store_available():
        migration["status"] = LIVE_RUNTIME_BRIDGE_STATUS
        migration["blocked_reason"] = ""
    else:
        migration["status"] = "deferred_pending_sqlite"
        migration["blocked_reason"] = String(runtime_status.get("reason", "sqlite_runtime_unavailable"))

    shell_data["migration"] = migration
    SaveService.save_v2_shell(shell_data)


func _reset_state() -> void:
    _close_runtime_store()
    shell_data = _build_default_shell()
    runtime_status = _build_runtime_status()
    _initialized = false


func _build_default_shell() -> Dictionary:
    return {
        "schema_version": SAVE_V2_SCHEMA_VERSION,
        "profile": {
            "child_id": "default",
        },
        "settings": {
            "sfx_enabled": true,
        },
        "learning_store": {
            "path": LEARNING_STORE_PATH,
            "schema_version": LEARNING_STORE_SCHEMA_VERSION,
            "driver": "sqlite",
            "status": "pending_runtime_integration",
        },
        "migration": {
            "status": "not_started",
            "source_path": SaveService.SAVE_V1_PATH,
            "source_schema_version": 1,
            "legacy_runtime_bridge": true,
            "learning_store_created": false,
            "runtime_store_available": false,
            "last_boot_unix": 0,
            "last_legacy_sync_unix": 0,
            "last_import_unix": 0,
            "legacy_completed_session_count": 0,
            "source_fingerprint": "",
            "last_import_fingerprint": "",
            "last_import_notes": "",
            "blocked_reason": "sqlite_runtime_unavailable",
        },
    }


func _build_default_legacy_projection() -> Dictionary:
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


func _normalize_shell(raw_shell: Variant) -> Dictionary:
    var normalized := _build_default_shell()
    if typeof(raw_shell) != TYPE_DICTIONARY:
        return normalized

    var source: Dictionary = raw_shell
    normalized["schema_version"] = max(
        SAVE_V2_SCHEMA_VERSION,
        int(source.get("schema_version", normalized["schema_version"]))
    )

    var profile: Dictionary = normalized["profile"]
    if typeof(source.get("profile", null)) == TYPE_DICTIONARY:
        profile = _merge_string_key_dictionary(profile, source["profile"])
    profile["child_id"] = String(profile.get("child_id", "default"))
    normalized["profile"] = profile

    var settings: Dictionary = normalized["settings"]
    if typeof(source.get("settings", null)) == TYPE_DICTIONARY:
        settings = _merge_string_key_dictionary(settings, source["settings"])
    settings["sfx_enabled"] = bool(settings.get("sfx_enabled", true))
    normalized["settings"] = settings

    var learning_store: Dictionary = normalized["learning_store"]
    if typeof(source.get("learning_store", null)) == TYPE_DICTIONARY:
        learning_store = _merge_string_key_dictionary(learning_store, source["learning_store"])
    learning_store["path"] = String(learning_store.get("path", LEARNING_STORE_PATH))
    learning_store["schema_version"] = max(
        1,
        int(learning_store.get("schema_version", LEARNING_STORE_SCHEMA_VERSION))
    )
    learning_store["driver"] = String(learning_store.get("driver", "sqlite"))
    learning_store["status"] = String(learning_store.get("status", "pending_runtime_integration"))
    normalized["learning_store"] = learning_store

    var migration: Dictionary = normalized["migration"]
    if typeof(source.get("migration", null)) == TYPE_DICTIONARY:
        migration = _merge_string_key_dictionary(migration, source["migration"])
    migration["status"] = String(migration.get("status", "not_started"))
    migration["source_path"] = String(migration.get("source_path", SaveService.SAVE_V1_PATH))
    migration["source_schema_version"] = max(1, int(migration.get("source_schema_version", 1)))
    migration["legacy_runtime_bridge"] = bool(migration.get("legacy_runtime_bridge", true))
    migration["learning_store_created"] = bool(migration.get("learning_store_created", false))
    migration["runtime_store_available"] = bool(migration.get("runtime_store_available", false))
    migration["last_boot_unix"] = max(0, int(migration.get("last_boot_unix", 0)))
    migration["last_legacy_sync_unix"] = max(0, int(migration.get("last_legacy_sync_unix", 0)))
    migration["last_import_unix"] = max(0, int(migration.get("last_import_unix", 0)))
    migration["legacy_completed_session_count"] = max(
        0,
        int(migration.get("legacy_completed_session_count", 0))
    )
    migration["source_fingerprint"] = String(migration.get("source_fingerprint", ""))
    migration["last_import_fingerprint"] = String(migration.get("last_import_fingerprint", ""))
    migration["last_import_notes"] = String(migration.get("last_import_notes", ""))
    migration["blocked_reason"] = String(
        migration.get("blocked_reason", "sqlite_runtime_unavailable")
    )
    normalized["migration"] = migration

    return normalized


func _build_runtime_status() -> Dictionary:
    var store_exists := FileAccess.file_exists(LEARNING_STORE_PATH)
    return {
        "path": LEARNING_STORE_PATH,
        "schema_version": LEARNING_STORE_SCHEMA_VERSION,
        "driver": "sqlite",
        "available": false,
        "connected": false,
        "file_exists": store_exists,
        "reason": "sqlite_runtime_unavailable",
    }


func _apply_legacy_profile_and_settings(legacy_save: Dictionary) -> void:
    if typeof(legacy_save.get("profile", null)) == TYPE_DICTIONARY:
        var profile: Dictionary = shell_data.get("profile", {}).duplicate(true)
        profile = _merge_string_key_dictionary(profile, legacy_save["profile"])
        profile["child_id"] = String(profile.get("child_id", "default"))
        shell_data["profile"] = profile

    if typeof(legacy_save.get("settings", null)) == TYPE_DICTIONARY:
        var settings: Dictionary = shell_data.get("settings", {}).duplicate(true)
        settings = _merge_string_key_dictionary(settings, legacy_save["settings"])
        settings["sfx_enabled"] = bool(settings.get("sfx_enabled", true))
        shell_data["settings"] = settings


func _refresh_shell_metadata(
    has_legacy_save: bool,
    legacy_save: Dictionary = {},
    import_result: Dictionary = {}
) -> void:
    var learning_store: Dictionary = shell_data.get("learning_store", {})
    learning_store["path"] = LEARNING_STORE_PATH
    learning_store["schema_version"] = LEARNING_STORE_SCHEMA_VERSION
    learning_store["driver"] = "sqlite"
    if is_runtime_store_available():
        if has_legacy_save:
            if bool(import_result.get("success", false)) or String(
                shell_data.get("migration", {}).get("status", "")
            ) == LEGACY_IMPORT_STATUS_COMPLETED:
                learning_store["status"] = "seeded_from_legacy_v1"
            else:
                learning_store["status"] = LEGACY_IMPORT_STATUS_PENDING
        else:
            learning_store["status"] = "runtime_store_ready"
    else:
        learning_store["status"] = "pending_runtime_integration"
    shell_data["learning_store"] = learning_store

    var migration: Dictionary = shell_data.get("migration", {})
    migration["source_path"] = SaveService.SAVE_V1_PATH
    migration["source_schema_version"] = 1
    migration["legacy_runtime_bridge"] = true
    migration["learning_store_created"] = bool(runtime_status.get("file_exists", false))
    migration["runtime_store_available"] = is_runtime_store_available()
    migration["last_boot_unix"] = int(Time.get_unix_time_from_system())

    if has_legacy_save:
        migration["legacy_completed_session_count"] = int(
            legacy_save.get("progression", {}).get("completed_session_count", 0)
        )
        if int(migration.get("last_legacy_sync_unix", 0)) <= 0:
            migration["last_legacy_sync_unix"] = int(Time.get_unix_time_from_system())
        if not import_result.is_empty():
            migration["source_fingerprint"] = String(import_result.get("source_fingerprint", ""))
            migration["last_import_notes"] = String(import_result.get("notes", ""))
            if bool(import_result.get("success", false)):
                migration["status"] = LEGACY_IMPORT_STATUS_COMPLETED
                migration["last_import_unix"] = int(import_result.get("migrated_at_unix", 0))
                migration["last_import_fingerprint"] = String(
                    import_result.get("source_fingerprint", "")
                )
                migration["blocked_reason"] = ""
            else:
                migration["status"] = LEGACY_IMPORT_STATUS_FAILED
                migration["blocked_reason"] = String(import_result.get("reason", "legacy_import_failed"))
        elif not is_runtime_store_available():
            migration["status"] = "deferred_pending_sqlite"
            migration["blocked_reason"] = String(
                runtime_status.get("reason", "sqlite_runtime_unavailable")
            )
        elif not _migration_status_is_terminal(String(migration.get("status", ""))):
            migration["status"] = LEGACY_IMPORT_STATUS_PENDING
            migration["blocked_reason"] = ""
    else:
        migration["legacy_completed_session_count"] = 0
        if is_runtime_store_available():
            migration["status"] = "runtime_store_ready"
            migration["blocked_reason"] = ""
        else:
            migration["status"] = "awaiting_runtime_store"
            migration["blocked_reason"] = String(
                runtime_status.get("reason", "sqlite_runtime_unavailable")
            )

    shell_data["migration"] = migration


func _open_runtime_store() -> Dictionary:
    var status := _build_runtime_status()
    if _sqlite_extension_resource == null and ResourceLoader.exists(SQLITE_EXTENSION_PATH):
        _sqlite_extension_resource = load(SQLITE_EXTENSION_PATH)
    if not ClassDB.class_exists(SQLITE_CLASS_NAME):
        status["reason"] = "sqlite_class_unavailable"
        return status

    var db_candidate: Object = ClassDB.instantiate(SQLITE_CLASS_NAME)
    if db_candidate == null:
        status["reason"] = "sqlite_instantiate_failed"
        return status

    db_candidate.path = LEARNING_STORE_PATH
    db_candidate.read_only = false
    db_candidate.verbosity_level = 0

    if not db_candidate.open_db():
        status["reason"] = String(db_candidate.error_message)
        if status["reason"].is_empty():
            status["reason"] = "sqlite_open_failed"
        return status

    for statement in SCHEMA_STATEMENTS:
        if not db_candidate.query(statement):
            status["reason"] = String(db_candidate.error_message)
            if status["reason"].is_empty():
                status["reason"] = "sqlite_schema_failed"
            db_candidate.close_db()
            return status

    _runtime_db = db_candidate
    status["available"] = true
    status["connected"] = true
    status["file_exists"] = FileAccess.file_exists(LEARNING_STORE_PATH)
    status["reason"] = ""
    return status


func _close_runtime_store() -> void:
    if _runtime_db == null:
        return
    if _runtime_db.has_method("close_db"):
        _runtime_db.close_db()
    _runtime_db = null


func _import_legacy_save(legacy_save: Dictionary) -> Dictionary:
    var result := {
        "attempted": false,
        "performed": false,
        "success": false,
        "status": LEGACY_IMPORT_STATUS_PENDING,
        "reason": "",
        "migrated_at": "",
        "migrated_at_unix": 0,
        "source_fingerprint": _build_legacy_source_fingerprint(legacy_save),
        "tables_seeded": LEGACY_SEEDED_TABLES.duplicate(),
        "tables_unseeded": LEGACY_UNSEEDED_TABLES.duplicate(),
        "legacy_completed_session_count": int(
            legacy_save.get("progression", {}).get("completed_session_count", 0)
        ),
        "notes": "",
    }
    var migration: Dictionary = shell_data.get("migration", {})
    if (
        String(migration.get("last_import_fingerprint", "")) == String(result["source_fingerprint"])
        and String(migration.get("status", "")) == LEGACY_IMPORT_STATUS_COMPLETED
    ):
        result["success"] = true
        result["status"] = LEGACY_IMPORT_STATUS_COMPLETED
        result["migrated_at_unix"] = int(migration.get("last_import_unix", 0))
        result["notes"] = String(migration.get("last_import_notes", ""))
        return result

    if _runtime_db == null:
        result["status"] = LEGACY_IMPORT_STATUS_FAILED
        result["reason"] = "sqlite_runtime_unavailable"
        return result

    result["attempted"] = true
    result["performed"] = true

    var learner_id := _extract_learner_id(legacy_save)
    var display_name := _extract_learner_display_name(legacy_save, learner_id)
    var migrated_at := _current_timestamp_text()
    result["migrated_at"] = migrated_at
    result["migrated_at_unix"] = int(Time.get_unix_time_from_system())
    result["notes"] = _build_legacy_import_notes(result)

    var symbol_catalog := _load_symbol_catalog()
    var node_rows := _build_legacy_node_progress_rows(legacy_save)
    var symbol_rows := _build_legacy_symbol_mastery_rows(legacy_save, symbol_catalog)
    var migration_id := _build_migration_id(learner_id)

    if not _execute_sql("BEGIN TRANSACTION;"):
        result["status"] = LEGACY_IMPORT_STATUS_FAILED
        result["reason"] = _get_runtime_db_error()
        _record_migration_log(migration_id, LEGACY_IMPORT_STATUS_FAILED, result["reason"])
        return result

    var statements: Array[String] = []
    statements.append(_build_learner_profile_upsert_sql(learner_id, migrated_at, display_name))
    for row in node_rows:
        statements.append(_build_node_progress_upsert_sql(learner_id, row))
    for row in symbol_rows:
        statements.append(_build_symbol_mastery_upsert_sql(learner_id, row))
    statements.append(
        _build_migration_log_upsert_sql(
            migration_id,
            SAVE_V2_SCHEMA_VERSION,
            migrated_at,
            LEGACY_IMPORT_STATUS_COMPLETED,
            String(result["notes"])
        )
    )

    for statement in statements:
        if _execute_sql(statement):
            continue

        var error_message := _get_runtime_db_error()
        _execute_sql("ROLLBACK;")
        result["status"] = LEGACY_IMPORT_STATUS_FAILED
        result["reason"] = error_message
        _record_migration_log(migration_id, LEGACY_IMPORT_STATUS_FAILED, error_message)
        return result

    if not _execute_sql("COMMIT;"):
        var commit_error := _get_runtime_db_error()
        _execute_sql("ROLLBACK;")
        result["status"] = LEGACY_IMPORT_STATUS_FAILED
        result["reason"] = commit_error
        _record_migration_log(migration_id, LEGACY_IMPORT_STATUS_FAILED, commit_error)
        return result

    result["success"] = true
    result["status"] = LEGACY_IMPORT_STATUS_COMPLETED
    return result


func _load_symbol_catalog() -> Dictionary:
    var catalog: Dictionary = {}
    var doc := _load_json_dictionary(SYMBOLS_PATH)
    for raw_symbol in doc.get("symbols", []):
        if typeof(raw_symbol) != TYPE_DICTIONARY:
            continue

        var symbol: Dictionary = raw_symbol
        var symbol_id := String(symbol.get("id", ""))
        if symbol_id.is_empty():
            continue

        catalog[symbol_id] = {
            "lexical_role": String(symbol.get("lexical_role", "noun")),
        }
    return catalog


func _build_legacy_node_progress_rows(legacy_save: Dictionary) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var progression: Dictionary = legacy_save.get("progression", {})
    var completed_node_ids := _extract_string_array(progression.get("completed_node_ids", []))
    var last_played_node_id := String(progression.get("last_played_node_id", ""))
    var nodes_doc := _load_json_dictionary(PROGRESSION_NODES_PATH)

    for raw_node in nodes_doc.get("nodes", []):
        if typeof(raw_node) != TYPE_DICTIONARY:
            continue

        var node_def: Dictionary = raw_node
        var node_id := String(node_def.get("node_id", ""))
        if node_id.is_empty():
            continue

        var status := "locked"
        var play_count := 0
        if completed_node_ids.has(node_id):
            status = "completed"
            play_count = 1
        elif not last_played_node_id.is_empty() and node_id == last_played_node_id:
            status = "in_progress"
            play_count = 1
        elif _node_prerequisites_are_completed(node_def, completed_node_ids):
            status = "available"

        rows.append({
            "node_id": node_id,
            "status": status,
            "play_count": play_count,
        })
    return rows


func _build_legacy_symbol_mastery_rows(
    legacy_save: Dictionary,
    symbol_catalog: Dictionary
) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var progression: Dictionary = legacy_save.get("progression", {})
    var raw_concepts: Variant = progression.get("concepts", {})
    if typeof(raw_concepts) != TYPE_DICTIONARY:
        return rows

    var concepts: Dictionary = raw_concepts
    for raw_symbol_id in concepts.keys():
        var symbol_id := String(raw_symbol_id)
        if symbol_id.is_empty():
            continue

        var raw_entry: Variant = concepts[raw_symbol_id]
        if typeof(raw_entry) != TYPE_DICTIONARY:
            continue

        var entry: Dictionary = raw_entry
        var exposure_count: int = max(0, int(entry.get("exposure_count", 0)))
        var independent_success_count: int = max(
            0,
            int(entry.get("independent_success_count", 0))
        )
        var supported_success_count: int = max(
            0,
            int(entry.get("supported_success_count", 0))
        )
        var mastery_state := "new"
        if (
            exposure_count > 0
            or independent_success_count > 0
            or supported_success_count > 0
            or bool(entry.get("learned", false))
        ):
            mastery_state = "practicing"

        var lexical_role := "noun"
        if typeof(symbol_catalog.get(symbol_id, null)) == TYPE_DICTIONARY:
            lexical_role = String(symbol_catalog[symbol_id].get("lexical_role", lexical_role))

        rows.append({
            "symbol_id": symbol_id,
            "lexical_role": lexical_role,
            "exposure_count": exposure_count,
            "independent_success_count": independent_success_count,
            "supported_success_count": supported_success_count,
            "stable_puzzle_count": 0,
            "distinct_exemplar_count": 1 if exposure_count > 0 else 0,
            "mastery_state": mastery_state,
        })
    return rows


func _build_legacy_source_fingerprint(legacy_save: Dictionary) -> String:
    var progression: Dictionary = legacy_save.get("progression", {})
    var concepts_payload: Array[Dictionary] = []
    var raw_concepts: Variant = progression.get("concepts", {})
    if typeof(raw_concepts) == TYPE_DICTIONARY:
        var concepts: Dictionary = raw_concepts
        var concept_ids: Array[String] = _extract_dictionary_keys_sorted(concepts)
        for concept_id in concept_ids:
            var entry: Variant = concepts.get(concept_id, {})
            if typeof(entry) != TYPE_DICTIONARY:
                continue

            var concept_entry: Dictionary = entry
            concepts_payload.append({
                "id": concept_id,
                "exposure_count": max(0, int(concept_entry.get("exposure_count", 0))),
                "independent_success_count": max(
                    0,
                    int(concept_entry.get("independent_success_count", 0))
                ),
                "supported_success_count": max(
                    0,
                    int(concept_entry.get("supported_success_count", 0))
                ),
                "learned": bool(concept_entry.get("learned", false)),
            })

    var payload := {
        "profile": _dictionary_to_sorted_key_rows(legacy_save.get("profile", {})),
        "settings": _dictionary_to_sorted_key_rows(legacy_save.get("settings", {})),
        "completed_session_count": max(0, int(progression.get("completed_session_count", 0))),
        "completed_node_ids": _extract_string_array(progression.get("completed_node_ids", [])),
        "last_played_node_id": String(progression.get("last_played_node_id", "")),
        "last_completed_node_id": String(progression.get("last_completed_node_id", "")),
        "concepts": concepts_payload,
    }
    return JSON.stringify(payload)


func _build_legacy_import_notes(import_result: Dictionary) -> String:
    return (
        "Seeded %s from save_v1.json; left %s unseeded to avoid fake session, round, "
        + "or puzzle-level history; completed_session_count=%d"
    ) % [
        _join_string_values(import_result.get("tables_seeded", [])),
        _join_string_values(import_result.get("tables_unseeded", [])),
        int(import_result.get("legacy_completed_session_count", 0)),
    ]


func _normalize_session_summary_payload(summary_payload: Dictionary) -> Dictionary:
    var learner_id := String(
        summary_payload.get(
            "learner_id",
            shell_data.get("profile", {}).get("child_id", "default")
        )
    )
    var session_run_id := String(summary_payload.get("session_run_id", ""))
    var node_id := String(summary_payload.get("node_id", ""))
    var session_plan: Dictionary = summary_payload.get("session_plan", {}).duplicate(true)
    var results := _extract_result_rows(summary_payload.get("results", []))

    if learner_id.is_empty() or session_run_id.is_empty() or node_id.is_empty():
        return {}
    if session_plan.is_empty() or results.is_empty():
        return {}

    var completed_at := String(summary_payload.get("completed_at", ""))
    if completed_at.is_empty():
        completed_at = _current_timestamp_text()

    var started_at := String(summary_payload.get("started_at", ""))
    if started_at.is_empty():
        started_at = completed_at

    var independent_round_count := 0
    var supported_round_count := 0
    for result in results:
        match String(result.get("outcome", "")):
            "independent_success":
                independent_round_count += 1
            "supported_success":
                supported_round_count += 1

    var track_id: Variant = _variant_or_null(summary_payload.get("track_id", null))
    var puzzle_template_id: Variant = _variant_or_null(
        summary_payload.get("puzzle_template_id", null)
    )

    return {
        "learner_id": learner_id,
        "session_run_id": session_run_id,
        "node_id": node_id,
        "track_id": track_id,
        "puzzle_type": _derive_session_puzzle_type(session_plan),
        "puzzle_template_id": puzzle_template_id,
        "started_at": started_at,
        "completed_at": completed_at,
        "round_count": results.size(),
        "independent_round_count": independent_round_count,
        "supported_round_count": supported_round_count,
        "star_count": _calculate_star_count(supported_round_count),
        "support_band": _derive_support_band(supported_round_count),
        "round_rows": _build_round_result_rows(
            learner_id,
            session_run_id,
            node_id,
            track_id,
            puzzle_template_id,
            session_plan,
            results
        ),
    }


func _build_round_result_rows(
    learner_id: String,
    session_run_id: String,
    node_id: String,
    track_id: Variant,
    puzzle_template_id: Variant,
    session_plan: Dictionary,
    results: Array[Dictionary]
) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    var session_puzzle_type := _derive_session_puzzle_type(session_plan)
    var raw_rounds: Array = session_plan.get("rounds", [])

    for index in results.size():
        var result: Dictionary = results[index]
        var round_def: Dictionary = {}
        if index < raw_rounds.size() and typeof(raw_rounds[index]) == TYPE_DICTIONARY:
            round_def = (raw_rounds[index] as Dictionary).duplicate(true)

        var shown_choice_count: int = max(
            0,
            int(result.get("shown_choice_count", round_def.get("choice_count", 0)))
        )
        var ended_choice_count: int = max(
            0,
            int(result.get("ended_choice_count", shown_choice_count))
        )
        var puzzle_type := String(round_def.get("puzzle_type", session_puzzle_type))

        rows.append({
            "round_result_id": _build_round_result_id(session_run_id, index),
            "session_run_id": session_run_id,
            "learner_id": learner_id,
            "node_id": node_id,
            "track_id": track_id,
            "puzzle_type": puzzle_type,
            "puzzle_template_id": puzzle_template_id,
            "target_symbol_id": _variant_or_null(
                round_def.get("target_symbol_id", round_def.get("concept_id", null))
            ),
            "target_exemplar_id": _variant_or_null(
                round_def.get("target_exemplar_id", result.get("target_exemplar_id", null))
            ),
            "composition_id": _variant_or_null(
                round_def.get("composition_id", result.get("composition_id", null))
            ),
            "prompt_role": _derive_prompt_role(round_def),
            "correct_choice_symbol_id": _variant_or_null(
                round_def.get("correct_choice_id", result.get("correct_choice_symbol_id", null))
            ),
            "wrong_attempt_count": max(0, int(result.get("wrong_attempt_count", 0))),
            "support_step_count": max(0, shown_choice_count - ended_choice_count),
            "outcome": _variant_or_null(result.get("outcome", null)),
            "response_time_ms": max(0, int(result.get("response_time_ms", 0))),
            "occurred_at": _variant_or_null(result.get("occurred_at", null)),
        })

    return rows


func _upsert_session_run_row(normalized: Dictionary) -> bool:
    return _execute_sql(
        """
        INSERT INTO session_run (
            session_run_id,
            learner_id,
            node_id,
            track_id,
            puzzle_type,
            puzzle_template_id,
            started_at,
            completed_at,
            round_count,
            independent_round_count,
            supported_round_count,
            star_count
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(session_run_id) DO UPDATE SET
            learner_id = excluded.learner_id,
            node_id = excluded.node_id,
            track_id = excluded.track_id,
            puzzle_type = excluded.puzzle_type,
            puzzle_template_id = excluded.puzzle_template_id,
            started_at = excluded.started_at,
            completed_at = excluded.completed_at,
            round_count = excluded.round_count,
            independent_round_count = excluded.independent_round_count,
            supported_round_count = excluded.supported_round_count,
            star_count = excluded.star_count;
        """,
        [
            String(normalized.get("session_run_id", "")),
            String(normalized.get("learner_id", "")),
            _variant_or_null(normalized.get("node_id", null)),
            normalized.get("track_id", null),
            _variant_or_null(normalized.get("puzzle_type", null)),
            normalized.get("puzzle_template_id", null),
            _variant_or_null(normalized.get("started_at", null)),
            _variant_or_null(normalized.get("completed_at", null)),
            int(normalized.get("round_count", 0)),
            int(normalized.get("independent_round_count", 0)),
            int(normalized.get("supported_round_count", 0)),
            int(normalized.get("star_count", 0)),
        ]
    )


func _replace_round_result_rows(normalized: Dictionary) -> bool:
    if not _execute_sql(
        "DELETE FROM round_result WHERE session_run_id = ?;",
        [String(normalized.get("session_run_id", ""))]
    ):
        return false

    var round_rows: Array[Dictionary] = normalized.get("round_rows", [])
    for row in round_rows:
        if not _execute_sql(
            """
            INSERT INTO round_result (
                round_result_id,
                session_run_id,
                learner_id,
                node_id,
                track_id,
                puzzle_type,
                puzzle_template_id,
                target_symbol_id,
                target_exemplar_id,
                composition_id,
                prompt_role,
                correct_choice_symbol_id,
                wrong_attempt_count,
                support_step_count,
                outcome,
                response_time_ms,
                occurred_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
            """,
            [
                String(row.get("round_result_id", "")),
                String(row.get("session_run_id", "")),
                String(row.get("learner_id", "")),
                row.get("node_id", null),
                row.get("track_id", null),
                row.get("puzzle_type", null),
                row.get("puzzle_template_id", null),
                row.get("target_symbol_id", null),
                row.get("target_exemplar_id", null),
                row.get("composition_id", null),
                row.get("prompt_role", null),
                row.get("correct_choice_symbol_id", null),
                int(row.get("wrong_attempt_count", 0)),
                int(row.get("support_step_count", 0)),
                row.get("outcome", null),
                int(row.get("response_time_ms", 0)),
                row.get("occurred_at", null),
            ]
        ):
            return false

    return true


func _upsert_node_progress_row(normalized: Dictionary) -> bool:
    var learner_id := String(normalized.get("learner_id", ""))
    var node_id := String(normalized.get("node_id", ""))
    if learner_id.is_empty() or node_id.is_empty():
        return false

    var existing_rows := _select_rows(
        """
        SELECT first_started_at, play_count, best_support_band
        FROM node_progress
        WHERE learner_id = ? AND node_id = ?;
        """,
        [learner_id, node_id]
    )
    var existing: Dictionary = existing_rows[0] if not existing_rows.is_empty() else {}
    var started_at := String(normalized.get("started_at", ""))
    var completed_at := String(normalized.get("completed_at", ""))
    var first_started_at := String(existing.get("first_started_at", started_at))
    if first_started_at.is_empty():
        first_started_at = started_at

    var play_count: int = max(0, int(existing.get("play_count", 0))) + 1
    var best_support_band := _pick_best_support_band(
        String(existing.get("best_support_band", "")),
        String(normalized.get("support_band", ""))
    )

    return _execute_sql(
        """
        INSERT INTO node_progress (
            learner_id,
            node_id,
            status,
            first_started_at,
            last_started_at,
            completed_at,
            play_count,
            best_support_band
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(learner_id, node_id) DO UPDATE SET
            status = excluded.status,
            first_started_at = excluded.first_started_at,
            last_started_at = excluded.last_started_at,
            completed_at = excluded.completed_at,
            play_count = excluded.play_count,
            best_support_band = excluded.best_support_band;
        """,
        [
            learner_id,
            node_id,
            "completed",
            _variant_or_null(first_started_at),
            _variant_or_null(started_at),
            _variant_or_null(completed_at),
            play_count,
            _variant_or_null(best_support_band),
        ]
    )


func _mark_runtime_store_live_with_legacy_bridge() -> void:
    var learning_store: Dictionary = shell_data.get("learning_store", {}).duplicate(true)
    learning_store["status"] = LIVE_RUNTIME_BRIDGE_STATUS
    shell_data["learning_store"] = learning_store

    var migration: Dictionary = shell_data.get("migration", {}).duplicate(true)
    migration["legacy_runtime_bridge"] = true
    migration["runtime_store_available"] = true
    migration["learning_store_created"] = bool(runtime_status.get("file_exists", false))
    migration["status"] = LIVE_RUNTIME_BRIDGE_STATUS
    migration["blocked_reason"] = ""
    shell_data["migration"] = migration


func _derive_session_puzzle_type(session_plan: Dictionary) -> String:
    var rounds: Array = session_plan.get("rounds", [])
    if not rounds.is_empty() and typeof(rounds[0]) == TYPE_DICTIONARY:
        return String((rounds[0] as Dictionary).get("puzzle_type", ""))
    return ""


func _derive_prompt_role(round_def: Dictionary) -> Variant:
    match String(round_def.get("puzzle_type", "")):
        "anchor_match":
            return "noun_picture_target"
        "reverse_anchor_match":
            return "symbol_target"
        "pair_completion":
            var formula_slots: Array = round_def.get("formula_slots", [])
            if not formula_slots.is_empty() and typeof(formula_slots[0]) == TYPE_DICTIONARY:
                if bool((formula_slots[0] as Dictionary).get("is_missing", false)):
                    return "composition_missing_modifier"
            return "composition_missing_head"
        _:
            return null


func _derive_support_band(supported_round_count: int) -> String:
    if supported_round_count <= 1:
        return "low_support"
    if supported_round_count <= 3:
        return "medium_support"
    return "high_support"


func _pick_best_support_band(existing_band: String, candidate_band: String) -> String:
    if existing_band.is_empty():
        return candidate_band
    if candidate_band.is_empty():
        return existing_band

    var existing_rank := int(SUPPORT_BAND_RANKS.get(existing_band, 999))
    var candidate_rank := int(SUPPORT_BAND_RANKS.get(candidate_band, 999))
    if candidate_rank < existing_rank:
        return candidate_band
    return existing_band


func _calculate_star_count(supported_round_count: int) -> int:
    if supported_round_count <= 1:
        return 3
    if supported_round_count <= 3:
        return 2
    return 1


func _extract_result_rows(raw_results: Variant) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    if typeof(raw_results) != TYPE_ARRAY:
        return out

    for raw_result in raw_results:
        if typeof(raw_result) != TYPE_DICTIONARY:
            continue
        out.append((raw_result as Dictionary).duplicate(true))
    return out


func _variant_or_null(value: Variant) -> Variant:
    if value == null:
        return null
    if typeof(value) == TYPE_STRING and String(value).is_empty():
        return null
    return value


func _build_round_result_id(session_run_id: String, round_index: int) -> String:
    return "%s_round_%02d" % [session_run_id, round_index]


func _build_learner_profile_upsert_sql(
    learner_id: String,
    created_at: String,
    display_name: String
) -> String:
    return (
        "INSERT INTO learner_profile (learner_id, created_at, display_name, active) VALUES (%s, %s, %s, 1) "
        + "ON CONFLICT(learner_id) DO UPDATE SET "
        + "display_name = excluded.display_name, "
        + "active = excluded.active;"
    ) % [
        _sql_value(learner_id),
        _sql_value(created_at),
        _sql_value(display_name),
    ]


func _build_node_progress_upsert_sql(learner_id: String, row: Dictionary) -> String:
    return (
        "INSERT INTO node_progress (learner_id, node_id, status, first_started_at, last_started_at, completed_at, play_count, best_support_band) "
        + "VALUES (%s, %s, %s, NULL, NULL, NULL, %d, NULL) "
        + "ON CONFLICT(learner_id, node_id) DO UPDATE SET "
        + "status = excluded.status, "
        + "play_count = excluded.play_count;"
    ) % [
        _sql_value(learner_id),
        _sql_value(String(row.get("node_id", ""))),
        _sql_value(String(row.get("status", "locked"))),
        max(0, int(row.get("play_count", 0))),
    ]


func _build_symbol_mastery_upsert_sql(learner_id: String, row: Dictionary) -> String:
    return (
        "INSERT INTO symbol_mastery (learner_id, symbol_id, lexical_role, exposure_count, independent_success_count, supported_success_count, stable_puzzle_count, distinct_exemplar_count, last_seen_at, mastery_state) "
        + "VALUES (%s, %s, %s, %d, %d, %d, %d, %d, NULL, %s) "
        + "ON CONFLICT(learner_id, symbol_id) DO UPDATE SET "
        + "lexical_role = excluded.lexical_role, "
        + "exposure_count = excluded.exposure_count, "
        + "independent_success_count = excluded.independent_success_count, "
        + "supported_success_count = excluded.supported_success_count, "
        + "stable_puzzle_count = excluded.stable_puzzle_count, "
        + "distinct_exemplar_count = excluded.distinct_exemplar_count, "
        + "mastery_state = excluded.mastery_state;"
    ) % [
        _sql_value(learner_id),
        _sql_value(String(row.get("symbol_id", ""))),
        _sql_value(String(row.get("lexical_role", "noun"))),
        max(0, int(row.get("exposure_count", 0))),
        max(0, int(row.get("independent_success_count", 0))),
        max(0, int(row.get("supported_success_count", 0))),
        max(0, int(row.get("stable_puzzle_count", 0))),
        max(0, int(row.get("distinct_exemplar_count", 0))),
        _sql_value(String(row.get("mastery_state", "new"))),
    ]


func _build_migration_log_upsert_sql(
    migration_id: String,
    target_schema_version: int,
    migrated_at: String,
    status: String,
    notes: String
) -> String:
    return (
        "INSERT INTO migration_log (migration_id, source_schema_version, target_schema_version, migrated_at, status, notes) "
        + "VALUES (%s, 1, %d, %s, %s, %s) "
        + "ON CONFLICT(migration_id) DO UPDATE SET "
        + "target_schema_version = excluded.target_schema_version, "
        + "migrated_at = excluded.migrated_at, "
        + "status = excluded.status, "
        + "notes = excluded.notes;"
    ) % [
        _sql_value(migration_id),
        max(1, target_schema_version),
        _sql_value(migrated_at),
        _sql_value(status),
        _sql_value(notes),
    ]


func _record_migration_log(migration_id: String, status: String, notes: String) -> void:
    var timestamp := _current_timestamp_text()
    _execute_sql(
        _build_migration_log_upsert_sql(
            migration_id,
            SAVE_V2_SCHEMA_VERSION,
            timestamp,
            status,
            notes
        )
    )


func _build_migration_id(learner_id: String) -> String:
    return "%s:%s" % [LEGACY_IMPORT_MIGRATION_ID_PREFIX, learner_id]


func _execute_sql(statement: String, bindings: Array = []) -> bool:
    if _runtime_db == null:
        return false

    if bindings.is_empty():
        return _runtime_db.query(statement)
    return _runtime_db.query_with_bindings(statement, bindings)


func _select_rows(statement: String, bindings: Array = []) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    if not _execute_sql(statement, bindings):
        return rows

    var query_result: Variant = _runtime_db.query_result
    if typeof(query_result) != TYPE_ARRAY:
        return rows

    for raw_row in query_result:
        if typeof(raw_row) != TYPE_DICTIONARY:
            continue
        rows.append((raw_row as Dictionary).duplicate(true))
    return rows


func _rollback_transaction() -> void:
    if _runtime_db == null:
        return
    _runtime_db.query("ROLLBACK;")


func _get_runtime_db_error() -> String:
    if _runtime_db == null:
        return "sqlite_runtime_unavailable"

    var error_message := String(_runtime_db.error_message)
    if error_message.is_empty():
        return "sqlite_query_failed"
    return error_message


func _current_timestamp_text() -> String:
    return str(int(Time.get_unix_time_from_system()))


func _extract_learner_id(legacy_save: Dictionary) -> String:
    var profile: Dictionary = legacy_save.get("profile", {})
    var learner_id := String(profile.get("child_id", shell_data.get("profile", {}).get("child_id", "default")))
    if learner_id.is_empty():
        return "default"
    return learner_id


func _extract_learner_display_name(legacy_save: Dictionary, learner_id: String) -> String:
    var profile: Dictionary = legacy_save.get("profile", {})
    var display_name := String(profile.get("display_name", ""))
    if display_name.is_empty():
        return learner_id
    return display_name


func _load_json_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}

    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}

    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed


func _node_prerequisites_are_completed(
    node_def: Dictionary,
    completed_node_ids: Array[String]
) -> bool:
    for prerequisite_node_id in _extract_string_array(node_def.get("prerequisite_node_ids", [])):
        if not completed_node_ids.has(prerequisite_node_id):
            return false
    return true


func _migration_status_is_terminal(status: String) -> bool:
    return (
        status == LEGACY_IMPORT_STATUS_COMPLETED
        or status == LEGACY_IMPORT_STATUS_FAILED
        or status == LEGACY_IMPORT_STATUS_DIRTY
    )


func _merge_string_key_dictionary(target: Dictionary, source: Dictionary) -> Dictionary:
    var merged := target.duplicate(true)
    for raw_key in source.keys():
        merged[String(raw_key)] = source[raw_key]
    return merged


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


func _extract_dictionary_keys_sorted(source: Dictionary) -> Array[String]:
    var keys: Array[String] = []
    for raw_key in source.keys():
        var key := String(raw_key)
        if key.is_empty():
            continue
        keys.append(key)
    keys.sort()
    return keys


func _dictionary_to_sorted_key_rows(raw_value: Variant) -> Array[Dictionary]:
    var rows: Array[Dictionary] = []
    if typeof(raw_value) != TYPE_DICTIONARY:
        return rows

    var source: Dictionary = raw_value
    for key in _extract_dictionary_keys_sorted(source):
        rows.append({
            "key": key,
            "value": source.get(key),
        })
    return rows


func _join_string_values(raw_values: Variant, separator: String = ", ") -> String:
    if typeof(raw_values) != TYPE_ARRAY:
        return ""

    var values: Array = raw_values
    var parts: Array[String] = []
    for value in values:
        parts.append(String(value))
    return separator.join(parts)


func _sql_value(value: Variant) -> String:
    if value == null:
        return "NULL"

    match typeof(value):
        TYPE_NIL:
            return "NULL"
        TYPE_BOOL:
            return "1" if bool(value) else "0"
        TYPE_INT, TYPE_FLOAT:
            return str(value)
        _:
            return "'%s'" % String(value).replace("'", "''")
