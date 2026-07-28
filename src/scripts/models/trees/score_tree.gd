class_name ScoreTree
extends RefCounted

var uid: String
var display_name: String
var root_uid: String
var nodes: Dictionary[String, ScoreTreeNode]
var _max_level: int


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
	_max_level = _calculate_max_level()


func _calculate_max_level() -> int:
	var max_level: int = 0

	for node: ScoreTreeNode in nodes.values():
		if node.get_level() > max_level:
			max_level = node.get_level()

	return max_level


func get_node(node_uid: String) -> ScoreTreeNode:
	return nodes[node_uid] as ScoreTreeNode


func get_root() -> ScoreTreeNode:
	return get_node(root_uid)


func get_parent(node_uid: String) -> ScoreTreeNode:
	var node: ScoreTreeNode = get_node(node_uid)
	return get_node(node.get_parent_uid())


func get_children(parent_uid: String) -> Array[ScoreTreeNode]:
	var children: Array[ScoreTreeNode] = []

	for node: ScoreTreeNode in nodes.values():
		if node.get_parent_uid() == parent_uid:
			children.append(node)

	return children


func get_max_level() -> int:
	return _max_level


func get_uid() -> String:
	return uid


func get_display_name() -> String:
	return display_name


func get_root_uid() -> String:
	return root_uid


func get_points(node_uid: String) -> int:
	var node: ScoreTreeNode = get_node(node_uid)
	return 2 * (get_max_level() - node.get_level()) + 1
