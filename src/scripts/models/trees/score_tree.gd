class_name ScoreTree
extends RefCounted

var uid: String
var display_name: String
var root_uid: String
var nodes: Dictionary[String, ScoreTreeNode]


func _init(
	tree_uid: String,
	tree_display_name: String,
	tree_root_uid: String,
	tree_nodes: Dictionary[String, ScoreTreeNode] = {}
) -> void:
	uid = tree_uid
	display_name = tree_display_name
	root_uid = tree_root_uid
	nodes = tree_nodes


func get_uid() -> String:
	return uid


func get_display_name() -> String:
	return display_name


func get_root_uid() -> String:
	return root_uid


func get_node_count() -> int:
	return nodes.size()


func add_node(node: ScoreTreeNode) -> void:
	nodes[node.get_uid()] = node


func has_node(node_uid: String) -> bool:
	return nodes.has(node_uid)


func get_node(node_uid: String) -> ScoreTreeNode:
	return nodes[node_uid] as ScoreTreeNode


func get_root() -> ScoreTreeNode:
	return get_node(root_uid)


func is_root_node(node_uid: String) -> bool:
	return node_uid == root_uid


func get_parent(node_uid: String) -> ScoreTreeNode:
	var node: ScoreTreeNode = get_node(node_uid)
	return get_node(node.get_parent_uid())


func get_children(parent_uid: String) -> Array[ScoreTreeNode]:
	var children: Array[ScoreTreeNode] = []

	for node: ScoreTreeNode in nodes.values():
		if node.get_parent_uid() == parent_uid:
			children.append(node)

	return children


func get_targetable_nodes() -> Array[ScoreTreeNode]:
	var targetable_nodes: Array[ScoreTreeNode] = []
	var node_uids: Array[String] = []

	for node: ScoreTreeNode in nodes.values():
		if is_valid_effect_target(node.get_uid()):
			node_uids.append(node.get_uid())

	node_uids.sort()

	for node_uid: String in node_uids:
		targetable_nodes.append(get_node(node_uid))

	return targetable_nodes


func get_path_to_root(node_uid: String) -> Array[ScoreTreeNode]:
	var path: Array[ScoreTreeNode] = []
	var current: ScoreTreeNode = get_node(node_uid)

	while true:
		path.push_front(current)

		if current.get_parent_uid().is_empty():
			break

		current = get_parent(current.get_uid())

	return path


func get_max_level() -> int:
	var max_level: int = 0

	for node: ScoreTreeNode in nodes.values():
		if node.get_level() > max_level:
			max_level = node.get_level()

	return max_level


func get_points_for_node(node_uid: String) -> int:
	var node: ScoreTreeNode = get_node(node_uid)
	return 2 * (get_max_level() - node.get_level()) + 1


func get_signed_points_for_effect(effect: FeatureEffect) -> int:
	if effect.get_tree_uid() != uid:
		push_error("Effect targets tree %s, not %s." % [effect.get_tree_uid(), uid])
		return 0

	if not is_valid_effect_target(effect.get_node_uid()):
		push_error("Effect target is invalid: %s" % effect.get_node_uid())
		return 0

	var impact: int = 1
	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return get_points_for_node(effect.get_node_uid()) * impact


func is_valid_effect_target(node_uid: String) -> bool:
	return has_node(node_uid) and not is_root_node(node_uid)
