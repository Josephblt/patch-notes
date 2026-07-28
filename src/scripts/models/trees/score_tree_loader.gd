class_name ScoreTreeLoader
extends RefCounted


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
		var tree: ScoreTree = load_from_json_file(path.path_join(json_file_name))

		if tree != null:
			trees.append(tree)

	return trees


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

	return from_json(data as Dictionary)


static func from_json(root_data: Dictionary) -> ScoreTree:
	var tree_uid: String = root_data.get("uid", "")
	var tree_display_name: String = root_data.get("display_name", "")
	var nodes: Dictionary[String, ScoreTreeNode] = {}

	_add_node_from_json(nodes, root_data, "", 1)

	return ScoreTree.new(
		tree_uid,
		tree_display_name,
		tree_uid,
		nodes
	)


static func _add_node_from_json(
	nodes: Dictionary[String, ScoreTreeNode],
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

	nodes[node.get_uid()] = node

	var children_data: Variant = node_data.get("children", [])

	if not children_data is Array:
		push_error("Score tree node children must be an array: %s" % node_uid)
		return

	for child_data: Variant in children_data:
		if not child_data is Dictionary:
			push_error("Score tree child must be an object under node: %s" % node_uid)
			continue

		_add_node_from_json(
			nodes,
			child_data as Dictionary,
			node_uid,
			level + 1
		)
