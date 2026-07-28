extends CanvasLayer

const SCORE_TREE_DIR: String = "res://data/score_trees"

var score_trees: Array[ScoreTree] = []
var feature_deck: FeatureDeck
var game_run: GameRun
var current_sprint: Sprint
var current_sprint_cards: Array[FeatureCard] = []
var card_buttons: Array[Button] = []

@onready var state_label: Label = $MarginContainer/VBoxContainer/StateLabel
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var preview_label: Label = $MarginContainer/VBoxContainer/PreviewLabel
@onready var selected_effects_label: Label = $MarginContainer/VBoxContainer/SelectedEffectsLabel
@onready var message_label: Label = $MarginContainer/VBoxContainer/MessageLabel
@onready var start_sprint_button: Button = $MarginContainer/VBoxContainer/ButtonRow/StartSprintButton
@onready var submit_sprint_button: Button = $MarginContainer/VBoxContainer/ButtonRow/SubmitSprintButton
@onready var ship_release_button: Button = $MarginContainer/VBoxContainer/ButtonRow/ShipReleaseButton


func _ready() -> void:
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)
	feature_deck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle()
	game_run = GameRun.new(feature_deck, score_trees)
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

	_set_message("Start a sprint.")
	_render_state()


func _on_start_sprint_button_pressed() -> void:
	current_sprint = game_run.start_sprint()

	if current_sprint == null:
		_set_message("No sprint available.")
		_render_state()
		return

	current_sprint_cards = current_sprint.get_feature_cards()
	_set_message("Release %d, sprint %d." % [
		game_run.get_current_release().get_number(),
		current_sprint.get_number(),
	])
	_render_state()


func _on_card_button_pressed(card_index: int) -> void:
	if current_sprint == null or current_sprint.is_submitted():
		return

	if card_index >= current_sprint_cards.size():
		return

	var card: FeatureCard = current_sprint_cards[card_index]
	var did_change_selection: bool = false
	var action_label: String = "Deselected"

	if card_buttons[card_index].button_pressed:
		did_change_selection = current_sprint.select_card(card.get_uid())
		action_label = "Selected"
	else:
		did_change_selection = current_sprint.deselect_card(card.get_uid())

	if did_change_selection:
		_set_message("%s: %s" % [action_label, card.get_title()])

	_render_state()


func _on_submit_sprint_button_pressed() -> void:
	if current_sprint == null:
		return

	var submitted_sprint_number: int = current_sprint.get_number()

	if not game_run.submit_sprint(current_sprint):
		_set_message("Pick at least one card before submitting sprint %d." % submitted_sprint_number)
		_render_state()
		return

	_set_message("Sprint %d submitted. Selected %d, discarded %d." % [
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
		_set_message("Release %d is not ready." % shipped_release_number)
		_render_state()
		return

	_set_message("Release %d shipped. Scores updated." % shipped_release_number)
	_render_state()


func _render_state() -> void:
	var release: Release = game_run.get_current_release()

	if release == null:
		state_label.text = "Run complete."
		score_label.text = "Scores: %s" % _format_scores()
		preview_label.text = "Preview: %s" % _format_preview_scores()
		selected_effects_label.text = _format_selected_effects()
		start_sprint_button.disabled = true
		submit_sprint_button.disabled = true
		ship_release_button.disabled = true
		_render_card_buttons()
		return

	var selected_count: int = 0
	var discarded_count: int = 0

	if current_sprint != null:
		selected_count = current_sprint.get_selected_card_count()
		discarded_count = current_sprint.get_discarded_card_count()

	state_label.text = "Release %d/%d | Sprints %d/%d | Current selected %d | Current discarded %d | Ready %s" % [
		release.get_number(),
		GameRun.RELEASE_COUNT,
		release.get_sprint_count(),
		Release.SPRINT_COUNT,
		selected_count,
		discarded_count,
		_format_bool(release.is_ready_to_ship()),
	]
	score_label.text = "Scores: %s" % _format_scores()
	preview_label.text = "Preview: %s" % _format_preview_scores()
	selected_effects_label.text = _format_selected_effects()

	start_sprint_button.disabled = current_sprint != null or release.is_ready_to_ship()
	submit_sprint_button.disabled = (
		current_sprint == null
		or current_sprint.get_selected_card_count() == 0
	)
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


func _set_message(message: String) -> void:
	message_label.text = message


func _format_scores() -> String:
	var output: String = ""

	for score_tree: ScoreTree in score_trees:
		if not output.is_empty():
			output += " | "

		output += "%s %d" % [
			score_tree.get_display_name(),
			game_run.get_score(score_tree.get_uid()),
		]

	return output


func _format_preview_scores() -> String:
	var output: String = ""

	for score_tree: ScoreTree in score_trees:
		if not output.is_empty():
			output += " | "

		output += "%s %d" % [
			score_tree.get_display_name(),
			game_run.get_preview_score(score_tree.get_uid(), current_sprint),
		]

	return output


func _format_selected_effects() -> String:
	var selected_cards: Array[FeatureCard] = []
	var release: Release = game_run.get_current_release()

	if release != null:
		selected_cards.append_array(release.get_selected_cards())

	if current_sprint != null:
		selected_cards.append_array(current_sprint.get_selected_cards())

	if selected_cards.is_empty():
		return "Selected effects: none"

	var lines: Array[String] = ["Selected effects:"]

	for card: FeatureCard in selected_cards:
		var effect_text: String = ""

		for effect: FeatureEffect in card.get_effects():
			if not effect_text.is_empty():
				effect_text += " | "

			effect_text += _describe_effect(effect)

		lines.append(effect_text)

	return _join_lines(lines)


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


func _calculate_effect_points(score_tree: ScoreTree, effect: FeatureEffect) -> int:
	var impact: int = 1

	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return score_tree.get_points(effect.get_node_uid()) * impact


func _join_lines(lines: Array[String]) -> String:
	var output: String = ""

	for line: String in lines:
		if not output.is_empty():
			output += "\n"

		output += line

	return output
