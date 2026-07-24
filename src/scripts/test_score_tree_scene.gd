extends CanvasLayer

const SCORE_TREE_DIR: String = "res://data/score_trees"

@onready var output_label: Label = $Label


func _ready() -> void:
	var score_trees: Array[ScoreTree] = ScoreTree.load_many_from_json_dir(SCORE_TREE_DIR)
	var generated_deck: FeatureDeck = FeatureDeckBuilder.build_from_score_trees(score_trees)
	var lines: Array[String] = []

	lines.append("PATCH NOTES")
	lines.append("")
	lines.append("Score tree load test")
	lines.append("Source: %s" % SCORE_TREE_DIR)
	lines.append("Trees loaded: %d" % score_trees.size())
	lines.append("Generated raw deck cards: %d" % generated_deck.remaining_count())

	for score_tree: ScoreTree in score_trees:
		lines.append("")
		lines.append_array(_describe_score_tree(score_tree))

	output_label.text = _join_lines(lines)


func _describe_score_tree(score_tree: ScoreTree) -> Array[String]:
	var lines: Array[String] = []
	var validation_errors: Array[String] = score_tree.validate()
	var targetable_nodes: Array[ScoreTreeNode] = score_tree.get_targetable_nodes()

	lines.append("%s" % score_tree.display_name)
	lines.append("UID: %s" % score_tree.uid)
	lines.append("Nodes: %d" % score_tree.nodes.size())
	lines.append("Targetable nodes: %d" % targetable_nodes.size())
	lines.append("Max level: %d" % score_tree.get_max_level())
	lines.append("Validation: %s" % _format_validation_status(validation_errors))

	if not validation_errors.is_empty():
		for error: String in validation_errors:
			lines.append("  ! %s" % error)

	for node: ScoreTreeNode in targetable_nodes:
		lines.append("  L%d %s -> %d points" % [
			node.level,
			node.display_name,
			score_tree.get_points_for_node(node.uid),
		])

	return lines


func _format_validation_status(validation_errors: Array[String]) -> String:
	if validation_errors.is_empty():
		return "OK"

	return "%d errors" % validation_errors.size()


func _join_lines(lines: Array[String]) -> String:
	var output: String = ""

	for line: String in lines:
		if not output.is_empty():
			output += "\n"

		output += line

	return output
