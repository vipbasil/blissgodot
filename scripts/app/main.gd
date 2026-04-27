extends Control

const MainProgressFlowProviderScript := preload("res://scripts/progression/main_progress_flow_provider.gd")
const SCREEN_SCENES := {
    "boot": preload("res://scenes/screens/boot_screen.tscn"),
    "home": preload("res://scenes/screens/home_screen.tscn"),
    "main_progress": preload("res://scenes/screens/main_progress_screen.tscn"),
    "session": preload("res://scenes/screens/session_screen.tscn"),
    "session_summary": preload("res://scenes/screens/session_summary_screen.tscn"),
    "parent_gate": preload("res://scenes/screens/parent_gate_screen.tscn"),
    "parent_progress": preload("res://scenes/screens/parent_progress_screen.tscn"),
}

@onready var screen_root: Control = %ScreenRoot

var current_screen: Control
var main_progress_flow_provider := MainProgressFlowProviderScript.new()
var pending_session_summary: Dictionary = {}
var active_session_context: Dictionary = {}


func _ready() -> void:
    navigate_to("boot")


func navigate_to(screen_id: String, payload: Dictionary = {}) -> void:
    if screen_id == "main_progress":
        payload = _build_main_progress_payload(payload)
    elif screen_id == "session":
        payload = _build_session_payload(payload)
        if payload.is_empty():
            return

    var scene: PackedScene = SCREEN_SCENES.get(screen_id)
    if scene == null:
        push_warning("Unknown screen id: %s" % screen_id)
        return

    if is_instance_valid(current_screen):
        current_screen.queue_free()

    current_screen = scene.instantiate()
    if current_screen.has_method("initialize"):
        current_screen.initialize(payload)
    screen_root.add_child(current_screen)
    if current_screen.has_signal("navigate_requested"):
        current_screen.navigate_requested.connect(_on_screen_navigate_requested)


func _on_screen_navigate_requested(screen_id: String, payload: Dictionary = {}) -> void:
    if screen_id == "session_summary":
        pending_session_summary = payload.duplicate(true)
        pending_session_summary["session_context"] = active_session_context.duplicate(true)
        navigate_to("session_summary", payload)
        return

    if screen_id == "summary_continue":
        _commit_pending_session_summary()
        return

    navigate_to(screen_id, payload)


func _build_main_progress_payload(payload: Dictionary) -> Dictionary:
    var just_completed_node_id: String = String(payload.get("just_completed_node_id", ""))
    return main_progress_flow_provider.build_model(just_completed_node_id)


func _build_session_payload(payload: Dictionary) -> Dictionary:
    var node_id: String = String(payload.get("node_id", ""))
    if node_id.is_empty():
        push_warning("Session route missing node_id")
        return {}

    var session_plan: Dictionary = payload.get("session_plan", {}).duplicate(true)
    if session_plan.is_empty():
        session_plan = ContentDB.build_session_plan_for_node(
            node_id,
            AppState.get_completed_session_count()
        )
    if session_plan.is_empty():
        push_warning("Missing session plan for node: %s" % node_id)
        return {}

    active_session_context = {
        "session_run_id": _build_session_run_id(node_id),
        "started_at": str(int(Time.get_unix_time_from_system())),
        "node_id": node_id,
        "session_plan": session_plan.duplicate(true),
    }

    return {
        "node_id": node_id,
        "session_plan": session_plan,
    }


func _commit_pending_session_summary() -> void:
    var node_id: String = String(pending_session_summary.get("node_id", ""))
    var results: Array[Dictionary] = _extract_results_array(pending_session_summary.get("results", []))
    var session_context: Dictionary = pending_session_summary.get("session_context", {}).duplicate(true)

    if not node_id.is_empty():
        AppState.commit_session_summary(node_id, results, session_context)

    pending_session_summary.clear()
    active_session_context.clear()
    navigate_to("main_progress", {
        "just_completed_node_id": node_id,
    })


func _extract_results_array(raw_results: Variant) -> Array[Dictionary]:
    var out: Array[Dictionary] = []
    if typeof(raw_results) != TYPE_ARRAY:
        return out

    for raw_entry in raw_results:
        if typeof(raw_entry) != TYPE_DICTIONARY:
            continue
        out.append((raw_entry as Dictionary).duplicate(true))
    return out


func _build_session_run_id(node_id: String) -> String:
    return "%s_%d" % [node_id, Time.get_ticks_usec()]
