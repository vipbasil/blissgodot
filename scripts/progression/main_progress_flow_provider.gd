extends RefCounted
class_name MainProgressFlowProvider

const MAX_VISIBLE_NODES := 5


func build_model(just_completed_node_id: String = "") -> Dictionary:
	var completed_sessions: int = AppState.get_completed_session_count()
	var completed_node_ids: Array[String] = AppState.get_completed_node_ids()
	var current_release_phase: int = ContentDB.get_unlocked_release_phase(completed_sessions)
	var released_nodes: Array[Dictionary] = _get_released_nodes(current_release_phase)
	var next_node_id: String = _find_next_node_id(released_nodes, completed_node_ids)
	var visible_nodes: Array[Dictionary] = _select_visible_nodes(released_nodes, next_node_id)
	var screen_nodes: Array[Dictionary] = []

	for node_def in visible_nodes:
		var node_id: String = String(node_def.get("node_id", ""))
		var node_view := {
			"node_id": node_id,
			"node_type": String(node_def.get("node_type", "")),
			"session_template_id": String(node_def.get("session_template_id", "")),
			"release_phase": int(node_def.get("release_phase", 1)),
			"primary_category_id": String(node_def.get("primary_category_id", "")),
			"sort_order": int(node_def.get("sort_order", 0)),
			"state": _resolve_node_state(node_def, completed_node_ids, next_node_id),
		}
		screen_nodes.append(node_view)

	var focused_node_id: String = _resolve_focused_node_id(
		screen_nodes,
		next_node_id,
		just_completed_node_id
	)

	return {
		"nodes": screen_nodes,
		"next_node_id": next_node_id,
		"focused_node_id": focused_node_id,
		"current_release_phase": current_release_phase,
		"just_completed_node_id": just_completed_node_id,
	}


func _get_released_nodes(current_release_phase: int) -> Array[Dictionary]:
	var released_nodes: Array[Dictionary] = []
	for node_def in ContentDB.get_progression_nodes():
		if int(node_def.get("release_phase", 999)) > current_release_phase:
			continue
		released_nodes.append(node_def)
	return released_nodes


func _find_next_node_id(node_defs: Array[Dictionary], completed_node_ids: Array[String]) -> String:
	for node_def in node_defs:
		var node_id: String = String(node_def.get("node_id", ""))
		if completed_node_ids.has(node_id):
			continue
		if _prerequisites_are_completed(node_def, completed_node_ids):
			return node_id
	return ""


func _select_visible_nodes(node_defs: Array[Dictionary], next_node_id: String) -> Array[Dictionary]:
	if node_defs.size() <= MAX_VISIBLE_NODES:
		return _duplicate_nodes(node_defs)

	var anchor_index: int = max(node_defs.size() - 1, 0)
	if not next_node_id.is_empty():
		for index in node_defs.size():
			if String(node_defs[index].get("node_id", "")) == next_node_id:
				anchor_index = index
				break

	var start_index: int = clamp(anchor_index - 1, 0, node_defs.size() - MAX_VISIBLE_NODES)
	var visible_nodes: Array[Dictionary] = []
	for index in range(start_index, min(start_index + MAX_VISIBLE_NODES, node_defs.size())):
		visible_nodes.append(node_defs[index].duplicate(true))
	return visible_nodes


func _duplicate_nodes(node_defs: Array[Dictionary]) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for node_def in node_defs:
		out.append(node_def.duplicate(true))
	return out


func _resolve_node_state(
	node_def: Dictionary,
	completed_node_ids: Array[String],
	next_node_id: String
) -> String:
	var node_id: String = String(node_def.get("node_id", ""))
	if completed_node_ids.has(node_id):
		return "completed"
	if node_id == next_node_id:
		return "next"
	if _prerequisites_are_completed(node_def, completed_node_ids):
		return "available"
	return "locked"


func _resolve_focused_node_id(
	nodes: Array[Dictionary],
	next_node_id: String,
	just_completed_node_id: String
) -> String:
	if not next_node_id.is_empty() and _has_node(nodes, next_node_id):
		return next_node_id

	if not just_completed_node_id.is_empty() and _has_node(nodes, just_completed_node_id):
		return just_completed_node_id

	var last_played_node_id: String = AppState.get_last_played_node_id()
	if _is_playable_node(nodes, last_played_node_id):
		return last_played_node_id

	for node in nodes:
		if _is_playable_state(String(node.get("state", ""))):
			return String(node.get("node_id", ""))

	return ""


func _prerequisites_are_completed(node_def: Dictionary, completed_node_ids: Array[String]) -> bool:
	for prerequisite_node_id in _extract_string_array(node_def.get("prerequisite_node_ids", [])):
		if not completed_node_ids.has(prerequisite_node_id):
			return false
	return true


func _has_node(nodes: Array[Dictionary], node_id: String) -> bool:
	if node_id.is_empty():
		return false
	for node in nodes:
		if String(node.get("node_id", "")) == node_id:
			return true
	return false


func _is_playable_node(nodes: Array[Dictionary], node_id: String) -> bool:
	if node_id.is_empty():
		return false
	for node in nodes:
		if String(node.get("node_id", "")) != node_id:
			continue
		return _is_playable_state(String(node.get("state", "")))
	return false


func _is_playable_state(state: String) -> bool:
	return state == "completed" or state == "next" or state == "available"


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
