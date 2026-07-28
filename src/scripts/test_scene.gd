extends CanvasLayer

const SCORE_TREE_DIR: String = "res://data/score_trees"
const CARD_MIN_HEIGHT: int = 260
const CARD_VERTICAL_PADDING: int = 20
const CARD_SECTION_SPACING: int = 12
const CARD_TITLE_CHARS_PER_LINE: int = 23
const CARD_BODY_CHARS_PER_LINE: int = 30
const CARD_TITLE_LINE_HEIGHT: int = 18
const CARD_BODY_LINE_HEIGHT: int = 16

var score_trees: Array[ScoreTree] = []
var feature_deck: FeatureDeck
var game_run: GameRun
var current_sprint: Sprint
var current_sprint_cards: Array[FeatureCard] = []
var card_buttons: Array[Button] = []
var card_title_labels: Array[Label] = []
var card_description_labels: Array[Label] = []
var card_consequence_labels: Array[Label] = []

@onready var state_label: Label = $MarginContainer/RunScroll/VBoxContainer/StateLabel
@onready var score_label: Label = $MarginContainer/RunScroll/VBoxContainer/ScoreLabel
@onready var preview_label: Label = $MarginContainer/RunScroll/VBoxContainer/PreviewLabel
@onready var selected_effects_label: Label = $MarginContainer/RunScroll/VBoxContainer/SelectedUpdatesScroll/SelectedEffectsLabel
@onready var start_sprint_button: Button = $MarginContainer/RunScroll/VBoxContainer/ButtonRow/StartSprintButton
@onready var submit_sprint_button: Button = $MarginContainer/RunScroll/VBoxContainer/ButtonRow/SubmitSprintButton
@onready var ship_release_button: Button = $MarginContainer/RunScroll/VBoxContainer/ButtonRow/ShipReleaseButton


func _ready() -> void:
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)
	feature_deck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle()
	game_run = GameRun.new(feature_deck, score_trees)
	card_buttons = [
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton1,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton2,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton3,
	]
	card_title_labels = [
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton1/CardContent/TitleLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton2/CardContent/TitleLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton3/CardContent/TitleLabel,
	]
	card_description_labels = [
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton1/CardContent/DescriptionLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton2/CardContent/DescriptionLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton3/CardContent/DescriptionLabel,
	]
	card_consequence_labels = [
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton1/CardContent/ConsequenceLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton2/CardContent/ConsequenceLabel,
		$MarginContainer/RunScroll/VBoxContainer/CardButtonContainer/CardButton3/CardContent/ConsequenceLabel,
	]

	start_sprint_button.pressed.connect(_on_start_sprint_button_pressed)
	submit_sprint_button.pressed.connect(_on_submit_sprint_button_pressed)
	ship_release_button.pressed.connect(_on_ship_release_button_pressed)

	for card_index: int in range(card_buttons.size()):
		card_buttons[card_index].pressed.connect(_on_card_button_pressed.bind(card_index))

	_render_state()


func _on_start_sprint_button_pressed() -> void:
	current_sprint = game_run.start_sprint()

	if current_sprint == null:
		_render_state()
		return

	current_sprint_cards = current_sprint.get_feature_cards()
	_render_state()


func _on_card_button_pressed(card_index: int) -> void:
	if current_sprint == null or current_sprint.is_submitted():
		return

	if card_index >= current_sprint_cards.size():
		return

	var card: FeatureCard = current_sprint_cards[card_index]

	if card_buttons[card_index].button_pressed:
		current_sprint.select_card(card.get_uid())
	else:
		current_sprint.deselect_card(card.get_uid())

	_render_state()


func _on_submit_sprint_button_pressed() -> void:
	if current_sprint == null:
		return

	if not game_run.submit_sprint(current_sprint):
		_render_state()
		return

	current_sprint = null
	current_sprint_cards = []
	_render_state()


func _on_ship_release_button_pressed() -> void:
	var release: Release = game_run.get_current_release()

	if release == null:
		return

	if not game_run.ship_current_release():
		_render_state()
		return

	_render_state()


func _render_state() -> void:
	var release: Release = game_run.get_current_release()

	if release == null:
		state_label.text = "Run complete."
		score_label.text = "Scores: %s" % _format_scores()
		preview_label.text = "Preview: %s" % _format_preview_scores()
		selected_effects_label.text = _format_selected_updates()
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
	selected_effects_label.text = _format_selected_updates()

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

		card_button.visible = true
		card_button.disabled = current_sprint == null or current_sprint.is_submitted()
		card_button.text = ""

		if not has_card:
			_render_card_button_content(card_index, null)
			card_button.button_pressed = false
			continue

		var card: FeatureCard = current_sprint_cards[card_index]
		_render_card_button_content(card_index, card)


func _render_card_button_content(card_index: int, card: FeatureCard) -> void:
	if card == null:
		card_title_labels[card_index].text = ""
		card_description_labels[card_index].text = ""
		card_consequence_labels[card_index].text = ""
		_resize_card_button(card_index, CARD_MIN_HEIGHT)
		return

	card_title_labels[card_index].text = card.get_title()
	card_description_labels[card_index].text = card.get_description()
	card_consequence_labels[card_index].text = card.get_consequence()
	_resize_card_button(card_index, _estimate_card_height(card))


func _resize_card_button(card_index: int, card_height: int) -> void:
	var current_size: Vector2 = card_buttons[card_index].custom_minimum_size
	card_buttons[card_index].custom_minimum_size = Vector2(
		current_size.x,
		max(CARD_MIN_HEIGHT, card_height)
	)


func _estimate_card_height(card: FeatureCard) -> int:
	return (
		CARD_VERTICAL_PADDING
		+ _estimate_text_height(
			card.get_title(),
			CARD_TITLE_CHARS_PER_LINE,
			CARD_TITLE_LINE_HEIGHT
		)
		+ _estimate_text_height(
			card.get_description(),
			CARD_BODY_CHARS_PER_LINE,
			CARD_BODY_LINE_HEIGHT
		)
		+ _estimate_text_height(
			card.get_consequence(),
			CARD_BODY_CHARS_PER_LINE,
			CARD_BODY_LINE_HEIGHT
		)
		+ CARD_SECTION_SPACING
	)


func _estimate_text_height(text: String, chars_per_line: int, line_height: int) -> int:
	var line_count: int = 0

	for paragraph: String in text.split("\n"):
		line_count += max(1, int(ceil(float(paragraph.length()) / chars_per_line)))

	return line_count * line_height


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


func _format_selected_updates() -> String:
	var selected_cards: Array[FeatureCard] = []
	var release: Release = game_run.get_current_release()

	if release != null:
		selected_cards.append_array(release.get_selected_cards())

	if current_sprint != null:
		selected_cards.append_array(current_sprint.get_selected_cards())

	if selected_cards.is_empty():
		return "Selected updates: none"

	var lines: Array[String] = ["Selected updates:"]

	for card: FeatureCard in selected_cards:
		lines.append(card.get_title())
		lines.append(_format_card_effects(card))

	return _join_lines(lines)


func _format_card_effects(card: FeatureCard) -> String:
	var effect_text: String = ""

	for effect: FeatureEffect in card.get_effects():
		if not effect_text.is_empty():
			effect_text += " | "

		effect_text += _describe_effect(effect)

	return effect_text


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
