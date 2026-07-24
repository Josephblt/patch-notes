extends CanvasLayer

const SCORE_TREE_DIR: String = "res://data/score_trees"

var score_trees: Array[ScoreTree] = []
var feature_deck: FeatureDeck
var console_lines: Array[String] = []
var dealt_count: int = 0

@onready var deal_button: Button = $MarginContainer/VBoxContainer/DealButton
@onready var console_scroll: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer
@onready var output_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Label


func _ready() -> void:
	score_trees = ScoreTree.load_many_from_json_dir(SCORE_TREE_DIR)
	feature_deck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle()
	deal_button.pressed.connect(_on_deal_button_pressed)

	_print_line("PATCH NOTES")
	_print_line("")
	_print_line("Test scene")
	_print_line("Source: %s" % SCORE_TREE_DIR)
	_print_line("Trees loaded: %d" % score_trees.size())
	_print_line("Deck Count: %d" % feature_deck._available_cards.size())

	for score_tree: ScoreTree in score_trees:
		_print_line("")
		_print_lines(_describe_score_tree(score_tree))

	_print_line("")
	_print_line("Press Deal to draw a random card.")


func _on_deal_button_pressed() -> void:
	if feature_deck == null or not feature_deck._available_cards.size() > 0:
		_print_line("")
		_print_line("Deck Count: 0")
		_print_line("Deck is empty.")
		deal_button.disabled = true
		return

	feature_deck.shuffle()
	var drawn_card: FeatureCard = feature_deck.draw()

	dealt_count += 1
	_print_line("")
	_print_line("Deal %d" % dealt_count)
	_print_line("Deck Count: %d" % feature_deck._available_cards.size())
	_print_lines(_describe_card(drawn_card))

	if not feature_deck._available_cards.size() == 0:
		deal_button.disabled = true


func _describe_card(card: FeatureCard) -> Array[String]:
	var lines: Array[String] = []

	lines.append("Card: %s" % card.get_title())
	lines.append("UID: %s" % card.get_uid())
	lines.append("Description: %s" % card.get_description())
	lines.append("Consequence: %s" % card.get_consequence())
	lines.append("Effects:")

	for effect: FeatureEffect in card.get_effects():
		lines.append("  %s" % _describe_effect(effect))

	return lines


func _describe_effect(effect: FeatureEffect) -> String:
	var score_tree: ScoreTree = _find_score_tree(effect.get_tree_uid())

	if score_tree == null:
		return "%s %s" % [
			_format_signed_points(0),
			effect.get_node_uid(),
		]

	var node: ScoreTreeNode = score_tree.get_node(effect.get_node_uid())

	return "%s %s / %s" % [
		_format_signed_points(score_tree.get_signed_points_for_effect(effect)),
		score_tree.get_display_name(),
		node.get_display_name(),
	]


func _find_score_tree(tree_uid: String) -> ScoreTree:
	for score_tree: ScoreTree in score_trees:
		if score_tree.uid == tree_uid:
			return score_tree

	return null


func _format_signed_points(points: int) -> String:
	if points >= 0:
		return "+%d" % points

	return "%d" % points


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
			node._display_name,
			score_tree.get_points_for_node(node._uid),
		])

	return lines


func _print_line(line: String) -> void:
	console_lines.append(line)
	_render_console()


func _print_lines(lines: Array[String]) -> void:
	for line: String in lines:
		console_lines.append(line)

	_render_console()


func _render_console() -> void:
	output_label.text = _join_lines(console_lines)
	call_deferred("_scroll_console_to_bottom")


func _scroll_console_to_bottom() -> void:
	console_scroll.scroll_vertical = int(console_scroll.get_v_scroll_bar().max_value)


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
