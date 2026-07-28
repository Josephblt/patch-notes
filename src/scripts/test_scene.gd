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
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)
	feature_deck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle()
	deal_button.pressed.connect(_on_deal_button_pressed)

	_print_line("PATCH NOTES")
	_print_line("")
	_print_line("Test scene")
	_print_line("Source: %s" % SCORE_TREE_DIR)
	_print_line("Trees loaded: %d" % score_trees.size())
	_print_line("Deck Count: %d" % feature_deck.get_available_card_count())

	for score_tree: ScoreTree in score_trees:
		_print_line("")
		_print_lines(_describe_score_tree(score_tree))

	_print_line("")
	_print_line("Press Deal to draw a random card.")


func _on_deal_button_pressed() -> void:
	if feature_deck == null or not feature_deck.has_cards():
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
	_print_line("Deck Count: %d" % feature_deck.get_available_card_count())
	_print_lines(_describe_card(drawn_card))

	if not feature_deck.has_cards():
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
		_format_signed_points(_calculate_effect_points(score_tree, effect)),
		score_tree.get_display_name(),
		node.get_display_name(),
	]


func _find_score_tree(tree_uid: String) -> ScoreTree:
	for score_tree: ScoreTree in score_trees:
		if score_tree.get_uid() == tree_uid:
			return score_tree

	return null


func _format_signed_points(points: int) -> String:
	if points >= 0:
		return "+%d" % points

	return "%d" % points


func _describe_score_tree(score_tree: ScoreTree) -> Array[String]:
	var lines: Array[String] = []
	var targetable_nodes: Array[ScoreTreeNode] = _collect_effect_nodes(score_tree)

	lines.append("%s" % score_tree.get_display_name())
	lines.append("UID: %s" % score_tree.get_uid())
	lines.append("Nodes: %d" % score_tree.nodes.size())
	lines.append("Targetable nodes: %d" % targetable_nodes.size())
	lines.append("Max level: %d" % score_tree.get_max_level())

	for node: ScoreTreeNode in targetable_nodes:
		lines.append("  L%d %s -> %d points" % [
			node.get_level(),
			node.get_display_name(),
			score_tree.get_points(node.get_uid()),
		])

	return lines


func _calculate_effect_points(score_tree: ScoreTree, effect: FeatureEffect) -> int:
	var impact: int = 1

	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return score_tree.get_points(effect.get_node_uid()) * impact


func _collect_effect_nodes(score_tree: ScoreTree) -> Array[ScoreTreeNode]:
	var effect_nodes: Array[ScoreTreeNode] = []
	var node_uids: Array[String] = []

	for node: ScoreTreeNode in score_tree.nodes.values():
		if node.get_uid() != score_tree.get_root_uid():
			node_uids.append(node.get_uid())

	node_uids.sort()

	for node_uid: String in node_uids:
		effect_nodes.append(score_tree.get_node(node_uid))

	return effect_nodes


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


func _join_lines(lines: Array[String]) -> String:
	var output: String = ""

	for line: String in lines:
		if not output.is_empty():
			output += "\n"

		output += line

	return output
