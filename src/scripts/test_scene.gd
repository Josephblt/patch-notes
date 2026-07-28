extends CanvasLayer

const SCORE_TREE_DIR: String = "res://data/score_trees"

var score_trees: Array[ScoreTree] = []
var feature_deck: FeatureDeck
var game_run: GameRun
var current_sprint: Sprint
var current_sprint_cards: Array[FeatureCard] = []
var console_lines: Array[String] = []
var card_buttons: Array[Button] = []

@onready var state_label: Label = $MarginContainer/VBoxContainer/StateLabel
@onready var start_sprint_button: Button = $MarginContainer/VBoxContainer/ButtonRow/StartSprintButton
@onready var submit_sprint_button: Button = $MarginContainer/VBoxContainer/ButtonRow/SubmitSprintButton
@onready var ship_release_button: Button = $MarginContainer/VBoxContainer/ButtonRow/ShipReleaseButton
@onready var console_scroll: ScrollContainer = $MarginContainer/VBoxContainer/ScrollContainer
@onready var output_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Label


func _ready() -> void:
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)
	feature_deck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle()
	game_run = GameRun.new(feature_deck)
	card_buttons = [
		$MarginContainer/VBoxContainer/CardButtonContainer/CardButton1,
		$MarginContainer/VBoxContainer/CardButtonContainer/CardButton2,
		$MarginContainer/VBoxContainer/CardButtonContainer/CardButton3,
	]

	start_sprint_button.pressed.connect(_on_start_sprint_button_pressed)
	submit_sprint_button.pressed.connect(_on_submit_sprint_button_pressed)
	ship_release_button.pressed.connect(_on_ship_release_button_pressed)

	for card_index: int in range(card_buttons.size()):
		card_buttons[card_index].pressed.connect(_on_card_button_pressed.bind(card_index))

	_print_line("PATCH NOTES")
	_print_line("")
	_print_line("Interactive lifecycle test")
	_print_line("Source: %s" % SCORE_TREE_DIR)
	_print_line("Trees loaded: %d" % score_trees.size())
	_print_line("Deck Count: %d" % feature_deck.get_size())

	for score_tree: ScoreTree in score_trees:
		_print_line("")
		_print_lines(_describe_score_tree(score_tree))

	_print_line("")
	_print_line("Start a sprint, select cards, submit 4 sprints, then ship the release.")
	_render_state()


func _on_start_sprint_button_pressed() -> void:
	current_sprint = game_run.start_sprint()

	if current_sprint == null:
		_print_line("")
		_print_line("Could not start sprint. Ship the release or check deck count.")
		_render_state()
		return

	current_sprint_cards = current_sprint.get_feature_cards()
	_print_line("")
	_print_line("Release %d / Sprint %d started" % [
		game_run.get_current_release().get_number(),
		current_sprint.get_number(),
	])
	_print_line("Deck Count: %d" % feature_deck.get_size())

	for card: FeatureCard in current_sprint_cards:
		_print_lines(_describe_card(card))

	_render_state()


func _on_card_button_pressed(card_index: int) -> void:
	if current_sprint == null or current_sprint.is_submitted():
		return

	if card_index >= current_sprint_cards.size():
		return

	var card: FeatureCard = current_sprint_cards[card_index]
	var did_change_selection: bool = false

	if card_buttons[card_index].button_pressed:
		did_change_selection = current_sprint.select_card(card.get_uid())
	else:
		did_change_selection = current_sprint.deselect_card(card.get_uid())

	if did_change_selection:
		_print_line("Selection changed: %s" % card.get_title())

	_render_state()


func _on_submit_sprint_button_pressed() -> void:
	if current_sprint == null:
		return

	var submitted_sprint_number: int = current_sprint.get_number()

	if not game_run.submit_sprint(current_sprint):
		_print_line("")
		_print_line("Could not submit sprint %d." % submitted_sprint_number)
		_render_state()
		return

	_print_line("")
	_print_line("Sprint %d submitted: selected %d, discarded %d" % [
		submitted_sprint_number,
		current_sprint.get_selected_card_count(),
		current_sprint.get_discarded_card_count(),
	])

	current_sprint = null
	current_sprint_cards = []
	_render_state()


func _on_ship_release_button_pressed() -> void:
	var release: Release = game_run.get_current_release()

	if release == null:
		return

	var shipped_release_number: int = release.get_number()

	if not game_run.ship_current_release():
		_print_line("")
		_print_line("Release %d is not ready to ship." % shipped_release_number)
		_render_state()
		return

	_print_line("")
	_print_line("Release %d shipped." % shipped_release_number)
	_render_state()


func _render_state() -> void:
	var release: Release = game_run.get_current_release()

	if release == null:
		state_label.text = "Run complete. Deck: %d" % feature_deck.get_size()
		start_sprint_button.disabled = true
		submit_sprint_button.disabled = true
		ship_release_button.disabled = true
		_render_card_buttons()
		return

	state_label.text = "Release %d | Sprints %d/%d | Selected %d | Discarded %d | Ready %s | Deck %d" % [
		release.get_number(),
		release.get_sprint_count(),
		Release.SPRINT_COUNT,
		release.get_selected_card_count(),
		release.get_discarded_card_count(),
		_format_bool(release.is_ready_to_ship()),
		feature_deck.get_size(),
	]

	start_sprint_button.disabled = current_sprint != null or release.is_ready_to_ship()
	submit_sprint_button.disabled = current_sprint == null
	ship_release_button.disabled = current_sprint != null or not release.is_ready_to_ship()
	_render_card_buttons()


func _render_card_buttons() -> void:
	for card_index: int in range(card_buttons.size()):
		var card_button: Button = card_buttons[card_index]
		var has_card: bool = card_index < current_sprint_cards.size()

		card_button.visible = has_card
		card_button.disabled = current_sprint == null or current_sprint.is_submitted()

		if not has_card:
			card_button.text = ""
			card_button.button_pressed = false
			continue

		var card: FeatureCard = current_sprint_cards[card_index]
		card_button.text = _format_card_button_text(card)


func _format_card_button_text(card: FeatureCard) -> String:
	var lines: Array[String] = []

	lines.append(card.get_title())
	lines.append(card.get_consequence())

	for effect: FeatureEffect in card.get_effects():
		lines.append(_describe_effect(effect))

	return _join_lines(lines)


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


func _format_bool(value: bool) -> String:
	if value:
		return "yes"

	return "no"


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
