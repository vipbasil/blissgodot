extends RefCounted
class_name MainProgressFlowProvider

const MAX_VISIBLE_NODES := 5


func build_model(just_completed_node_id: String = "") -> Dictionary:
	var completed_sessions: int = AppState.get_completed_session_count()
	var completed_node_ids: Array[String] = AppState.get_completed_node_ids()
	var current_release_phase: int = ContentDB.get_unlocked_release_phase(completed_sessions)
	var released_nodes: Array[Dictionary] = _get_released_nodes(current_release_phase)
	var next_node_id: String = _find_next_node_id(released_nodes, completed_node_ids)
	var display_nodes: Array[Dictionary] = _build_display_nodes(released_nodes, completed_node_ids, next_node_id)
	var visible_nodes: Array[Dictionary] = _select_visible_nodes(
		display_nodes,
		_resolve_visible_anchor_id(just_completed_node_id, next_node_id)
	)
	var screen_nodes: Array[Dictionary] = []

	for index in visible_nodes.size():
		var node_def: Dictionary = visible_nodes[index]
		var node_id: String = String(node_def.get("node_id", ""))
		var node_view := {
			"node_id": node_id,
			"node_type": String(node_def.get("node_type", "")),
			"puzzle_type": String(node_def.get("puzzle_type", "")),
			"session_template_id": String(node_def.get("session_template_id", "")),
			"release_phase": int(node_def.get("release_phase", 1)),
			"primary_category_id": String(node_def.get("primary_category_id", "")),
			"sort_order": int(node_def.get("sort_order", 0)),
			"display_order": index + 1,
			"state": String(node_def.get("state", "locked")),
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


func _build_display_nodes(
	node_defs: Array[Dictionary],
	completed_node_ids: Array[String],
	next_node_id: String
) -> Array[Dictionary]:
	var grouped_nodes: Dictionary = {}
	var group_order: Array[String] = []

	for node_def in node_defs:
		var puzzle_type: String = String(node_def.get("puzzle_type", "anchor_match"))
		if not grouped_nodes.has(puzzle_type):
			grouped_nodes[puzzle_type] = []
			group_order.append(puzzle_type)
		var entries: Array = grouped_nodes[puzzle_type]
		entries.append(node_def)
		grouped_nodes[puzzle_type] = entries

	var out: Array[Dictionary] = []
	for puzzle_type in group_order:
		var entries: Array = grouped_nodes.get(puzzle_type, [])
		var cluster_nodes: Array[Dictionary] = []
		for entry in entries:
			if typeof(entry) == TYPE_DICTIONARY:
				cluster_nodes.append((entry as Dictionary).duplicate(true))
		if cluster_nodes.is_empty():
			continue
		out.append(_build_display_node_for_cluster(cluster_nodes, completed_node_ids, next_node_id))
	return out


func _build_display_node_for_cluster(
	cluster_nodes: Array[Dictionary],
	completed_node_ids: Array[String],
	next_node_id: String
) -> Dictionary:
	var first_node: Dictionary = cluster_nodes[0].duplicate(true)
	var launch_node: Dictionary = {}
	var last_completed_node: Dictionary = {}
	var has_completed := false
	var all_completed := true

	for node_def in cluster_nodes:
		var node_id: String = String(node_def.get("node_id", ""))
		if completed_node_ids.has(node_id):
			last_completed_node = node_def.duplicate(true)
			has_completed = true
			continue
		all_completed = false
		if node_id == next_node_id:
			launch_node = node_def.duplicate(true)
			break
		if launch_node.is_empty() and _prerequisites_are_completed(node_def, completed_node_ids):
			launch_node = node_def.duplicate(true)

	var representative: Dictionary = launch_node if not launch_node.is_empty() else last_completed_node
	if representative.is_empty():
		representative = first_node.duplicate(true)

	var state := "locked"
	if all_completed:
		state = "completed"
	elif not launch_node.is_empty() and String(launch_node.get("node_id", "")) == next_node_id:
		state = "next"
	elif not launch_node.is_empty():
		state = "available"
	elif has_completed:
		state = "completed"

	var display_node: Dictionary = representative.duplicate(true)
	display_node["state"] = state
	return display_node


func _select_visible_nodes(node_defs: Array[Dictionary], anchor_node_id: String) -> Array[Dictionary]:
	if node_defs.size() <= MAX_VISIBLE_NODES:
		return _duplicate_nodes(node_defs)

	var anchor_index: int = max(node_defs.size() - 1, 0)
	if not anchor_node_id.is_empty():
		for index in node_defs.size():
			if String(node_defs[index].get("node_id", "")) == anchor_node_id:
				anchor_index = index
				break

	var start_index: int = clamp(anchor_index - 2, 0, node_defs.size() - MAX_VISIBLE_NODES)
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
	if not just_completed_node_id.is_empty() and _has_node(nodes, just_completed_node_id):
		return just_completed_node_id

	if not next_node_id.is_empty() and _has_node(nodes, next_node_id):
		return next_node_id

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


func _resolve_visible_anchor_id(just_completed_node_id: String, next_node_id: String) -> String:
	if not just_completed_node_id.is_empty():
		return just_completed_node_id
	return next_node_id


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
