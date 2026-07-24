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


static func load_from_json_file(path: String) -> ScoreTree:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Could not open score tree JSON file: %s" % path)
		return null

	var json_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Could not parse score tree JSON file: %s. %s" % [
			path,
			json.get_error_message(),
		])
		return null

	var data: Variant = json.data

	if not data is Dictionary:
		push_error("Score tree JSON root must be an object: %s" % path)
		return null

	var root_data: Dictionary = data as Dictionary
	return ScoreTree.from_json(root_data)


static func load_many_from_json_dir(path: String) -> Array[ScoreTree]:
	var trees: Array[ScoreTree] = []
	var dir: DirAccess = DirAccess.open(path)

	if dir == null:
		push_error("Could not open score tree JSON directory: %s" % path)
		return trees

	var file_names: Array[String] = []

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == "json":
			file_names.append(file_name)

		file_name = dir.get_next()

	dir.list_dir_end()
	file_names.sort()

	for json_file_name: String in file_names:
		var tree: ScoreTree = ScoreTree.load_from_json_file(path.path_join(json_file_name))

		if tree != null:
			trees.append(tree)

	return trees


static func from_json(root_data: Dictionary) -> ScoreTree:
	var tree_uid: String = root_data.get("uid", "")
	var tree_display_name: String = root_data.get("display_name", "")

	var tree: ScoreTree = ScoreTree.new(
		tree_uid,
		tree_display_name,
		tree_uid
	)

	_add_node_from_json(tree, root_data, "", 1)

	return tree


static func _add_node_from_json(
	tree: ScoreTree,
	node_data: Dictionary,
	parent_uid: String,
	level: int
) -> void:
	var node_uid: String = node_data.get("uid", "")
	var node_display_name: String = node_data.get("display_name", "")

	var node: ScoreTreeNode = ScoreTreeNode.new(
		node_uid,
		node_display_name,
		parent_uid,
		level
	)

	tree.add_node(node)

	var children_data: Variant = node_data.get("children", [])

	if not children_data is Array:
		push_error("Score tree node children must be an array: %s" % node_uid)
		return

	for child_data: Variant in children_data:
		if not child_data is Dictionary:
			push_error("Score tree child must be an object under node: %s" % node_uid)
			continue

		_add_node_from_json(
			tree,
			child_data as Dictionary,
			node_uid,
			level + 1
		)


func add_node(node: ScoreTreeNode) -> void:
	nodes[node.uid] = node


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
	return get_node(node.parent_uid)


func get_children(parent_uid: String) -> Array[ScoreTreeNode]:
	var children: Array[ScoreTreeNode] = []

	for node: ScoreTreeNode in nodes.values():
		if node.parent_uid == parent_uid:
			children.append(node)

	return children


func get_targetable_nodes() -> Array[ScoreTreeNode]:
	var targetable_nodes: Array[ScoreTreeNode] = []
	var node_uids: Array[String] = []

	for node: ScoreTreeNode in nodes.values():
		if is_valid_effect_target(node.uid):
			node_uids.append(node.uid)

	node_uids.sort()

	for node_uid: String in node_uids:
		targetable_nodes.append(get_node(node_uid))

	return targetable_nodes


func get_path_to_root(node_uid: String) -> Array[ScoreTreeNode]:
	var path: Array[ScoreTreeNode] = []
	var current: ScoreTreeNode = get_node(node_uid)

	while true:
		path.push_front(current)

		if current.is_root():
			break

		current = get_parent(current.uid)

	return path


func get_max_level() -> int:
	var max_level: int = 0

	for node: ScoreTreeNode in nodes.values():
		if node.level > max_level:
			max_level = node.level

	return max_level


func get_points_for_node(node_uid: String) -> int:
	var node: ScoreTreeNode = get_node(node_uid)
	return 2 * (get_max_level() - node.level) + 1


func get_signed_points_for_effect(effect: FeatureEffect) -> int:
	if effect.tree_uid != uid:
		push_error("Effect targets tree %s, not %s." % [effect.tree_uid, uid])
		return 0

	if not is_valid_effect_target(effect.node_uid):
		push_error("Effect target is invalid: %s" % effect.node_uid)
		return 0

	return get_points_for_node(effect.node_uid) * effect.get_sign()


func is_valid_effect_target(node_uid: String) -> bool:
	return has_node(node_uid) and not is_root_node(node_uid)


func validate() -> Array[String]:
	var errors: Array[String] = []

	if uid.is_empty():
		errors.append("Tree uid is required.")

	if display_name.is_empty():
		errors.append("Tree display name is required.")

	if root_uid.is_empty():
		errors.append("Root uid is required.")

	if not nodes.has(root_uid):
		errors.append("Root node does not exist.")

	for node: ScoreTreeNode in nodes.values():
		if node.uid.is_empty():
			errors.append("Node uid is required.")

		if node.display_name.is_empty():
			errors.append("Node display name is required: %s" % node.uid)

		if node.level < 1:
			errors.append("Node level must be 1 or higher: %s" % node.uid)

		if node.uid == root_uid:
			if not node.is_root():
				errors.append("Root node cannot have a parent: %s" % node.uid)

			if node.level != 1:
				errors.append("Root node must be level 1: %s" % node.uid)
		else:
			if node.is_root():
				errors.append("Only the root node can be parentless: %s" % node.uid)
			elif not nodes.has(node.parent_uid):
				errors.append("Node parent does not exist: %s -> %s" % [
					node.uid,
					node.parent_uid,
				])

	errors.append_array(_validate_no_cycles())

	return errors


func _validate_no_cycles() -> Array[String]:
	var errors: Array[String] = []

	for node: ScoreTreeNode in nodes.values():
		var seen: Dictionary[String, bool] = {}
		var current: ScoreTreeNode = node

		while not current.is_root():
			if seen.has(current.uid):
				errors.append("Cycle detected at node: %s" % current.uid)
				break

			seen[current.uid] = true

			if not nodes.has(current.parent_uid):
				break

			current = get_parent(current.uid)

	return errors
