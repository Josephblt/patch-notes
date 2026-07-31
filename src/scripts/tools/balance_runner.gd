extends CanvasLayer


const SCORE_TREE_DIR: String = "res://data/score_trees"
const BASELINE_BEHAVIOR: String = "random_count"
const DEFAULT_GAME_COUNT: int = 200
const DEFAULT_BEHAVIOR: String = "vh_vh"
const DEFAULT_SEED: int = 310731
const DEFAULT_OUTPUT_PATH: String = "user://balance_runner_results.csv"
const SCORE_LEVELS: Array[String] = [
	"vh",
	"h",
	"m",
	"l",
	"vl",
]

var score_trees: Array[ScoreTree] = []
var score_tree_by_name: Dictionary[String, ScoreTree] = {}
var last_rows: Array[Dictionary] = []

@export var selected_behavior: String = DEFAULT_BEHAVIOR
@export var game_count: int = DEFAULT_GAME_COUNT
@export var seed: int = DEFAULT_SEED
@export var random_seed: bool = false
@export var output_path: String = DEFAULT_OUTPUT_PATH

@onready var behavior_options: OptionButton = $MarginContainer/VBoxContainer/ControlRow/BehaviorOptions
@onready var game_count_spin_box: SpinBox = $MarginContainer/VBoxContainer/ControlRow/GameCountSpinBox
@onready var seed_spin_box: SpinBox = $MarginContainer/VBoxContainer/ControlRow/SeedSpinBox
@onready var random_seed_check_box: CheckBox = $MarginContainer/VBoxContainer/ControlRow/RandomSeedCheckBox
@onready var output_path_line_edit: LineEdit = $MarginContainer/VBoxContainer/OutputRow/OutputPathLineEdit
@onready var band_divider_1_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider1SpinBox
@onready var band_divider_2_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider2SpinBox
@onready var band_divider_3_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider3SpinBox
@onready var band_divider_4_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider4SpinBox
@onready var run_button: Button = $MarginContainer/VBoxContainer/ControlRow/RunButton
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var summary_label: Label = $MarginContainer/VBoxContainer/SummaryLabel
@onready var graph: Control = $MarginContainer/VBoxContainer/Graph


func _ready() -> void:
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)

	for score_tree: ScoreTree in score_trees:
		score_tree_by_name[score_tree.get_display_name()] = score_tree

	if OS.get_cmdline_user_args().size() > 0:
		_run_from_command_line()
		return

	_configure_controls()
	run_button.pressed.connect(_on_run_button_pressed)
	random_seed_check_box.toggled.connect(_on_random_seed_check_box_toggled)
	summary_label.text = "Ready."


func _run_from_command_line() -> void:
	var options: Dictionary = _parse_options()
	var rows: Array[Dictionary] = run_dataset(
		options.get("behavior", selected_behavior),
		options.get("games", game_count),
		options.get("seed", seed)
	)

	_write_csv(options.get("output", output_path), rows)
	get_tree().quit()


func _configure_controls() -> void:
	behavior_options.clear()

	for behavior: String in _get_supported_behaviors():
		behavior_options.add_item(behavior)

	var selected_index: int = _get_supported_behaviors().find(selected_behavior)

	if selected_index < 0:
		selected_index = 0

	behavior_options.select(selected_index)
	game_count_spin_box.value = game_count
	seed_spin_box.value = seed
	random_seed_check_box.button_pressed = random_seed
	output_path_line_edit.text = output_path
	_configure_band_divider_controls()
	_on_random_seed_check_box_toggled(random_seed_check_box.button_pressed)


func _on_run_button_pressed() -> void:
	run_button.disabled = true
	summary_label.text = "Running..."

	await get_tree().process_frame

	var behavior: String = behavior_options.get_item_text(behavior_options.selected)
	var selected_game_count: int = int(game_count_spin_box.value)
	var selected_seed: int = int(seed_spin_box.value)
	var selected_output_path: String = output_path_line_edit.text
	var selected_score_band_dividers: Array[int] = _get_score_band_dividers_from_controls()
	var game_seeds: Array[int] = []

	if random_seed_check_box.button_pressed:
		game_seeds = _generate_random_game_seeds(selected_game_count)
	else:
		game_seeds = _generate_deterministic_game_seeds(selected_game_count, selected_seed)

	last_rows = await _run_dataset_with_progress(behavior, game_seeds)
	_write_csv(selected_output_path, last_rows)
	var score_axis_bound: int = _calculate_score_axis_bound()
	graph.call(
		"set_series",
		_build_frequency_series(last_rows),
		-score_axis_bound,
		score_axis_bound,
		selected_score_band_dividers
	)

	summary_label.text = _format_seed_summary(
		selected_seed,
		random_seed_check_box.button_pressed,
		game_seeds.size()
	)
	run_button.disabled = false


func _run_dataset_with_progress(
	behavior: String,
	game_seeds: Array[int]
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var behavior_names: Array[String] = _get_behaviors_to_run(behavior)
	var progress_by_behavior: Dictionary[String, int] = {}
	var selected_game_count: int = game_seeds.size()

	for behavior_name: String in behavior_names:
		progress_by_behavior[behavior_name] = 0

	_render_runner_progress(behavior, selected_game_count, progress_by_behavior)
	await get_tree().process_frame

	for behavior_index: int in range(behavior_names.size()):
		var behavior_name: String = behavior_names[behavior_index]

		for game_number: int in range(1, selected_game_count + 1):
			rows.append(_play_game(behavior_name, game_number, game_seeds[game_number - 1]))
			progress_by_behavior[behavior_name] = game_number
			_render_runner_progress(behavior, selected_game_count, progress_by_behavior)
			await get_tree().process_frame

	return rows


func _render_runner_progress(
	selected_behavior_name: String,
	selected_game_count: int,
	progress_by_behavior: Dictionary[String, int]
) -> void:
	var parts: PackedStringArray = []

	for behavior_name: String in _get_progress_behavior_names(selected_behavior_name):
		var completed_count: int = progress_by_behavior.get(behavior_name, 0)
		var percent_complete: int = 0

		if selected_game_count > 0:
			percent_complete = int(round(
				(float(completed_count) / float(selected_game_count)) * 100.0
			))

		parts.append("%s - %d/%d - %d%%" % [
			_format_progress_behavior_name(behavior_name),
			selected_game_count,
			completed_count,
			percent_complete,
		])

	progress_label.text = " | ".join(parts)


func _get_progress_behavior_names(selected_behavior_name: String) -> Array[String]:
	if selected_behavior_name == BASELINE_BEHAVIOR:
		return [BASELINE_BEHAVIOR]

	return [selected_behavior_name, BASELINE_BEHAVIOR]


func _format_progress_behavior_name(behavior_name: String) -> String:
	if behavior_name == BASELINE_BEHAVIOR:
		return "Random"

	return behavior_name.to_upper()


func _on_random_seed_check_box_toggled(is_random_seed: bool) -> void:
	seed_spin_box.editable = not is_random_seed


func _parse_options() -> Dictionary:
	var options: Dictionary = {
		"games": game_count,
		"behavior": selected_behavior,
		"seed": seed,
		"output": output_path,
	}

	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--games="):
			options["games"] = argument.trim_prefix("--games=").to_int()
		elif argument.begins_with("--behavior="):
			options["behavior"] = argument.trim_prefix("--behavior=")
		elif argument.begins_with("--seed="):
			options["seed"] = argument.trim_prefix("--seed=").to_int()
		elif argument.begins_with("--output="):
			options["output"] = argument.trim_prefix("--output=")

	return options


func run_dataset(behavior: String, selected_game_count: int, selected_seed: int) -> Array[Dictionary]:
	return _run_dataset_with_game_seeds(
		behavior,
		_generate_deterministic_game_seeds(selected_game_count, selected_seed)
	)


func _run_dataset_with_game_seeds(behavior: String, game_seeds: Array[int]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var behavior_names: Array[String] = _get_behaviors_to_run(behavior)

	for behavior_name: String in behavior_names:
		rows.append_array(_play_behavior(behavior_name, game_seeds))

	return rows


func _get_behaviors_to_run(behavior: String) -> Array[String]:
	var behavior_names: Array[String] = [BASELINE_BEHAVIOR]

	if behavior != BASELINE_BEHAVIOR:
		behavior_names.append(behavior)

	return behavior_names


func _play_behavior(behavior: String, game_seeds: Array[int]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	for game_number: int in range(1, game_seeds.size() + 1):
		rows.append(_play_game(behavior, game_number, game_seeds[game_number - 1]))

	return rows


func _play_game(behavior: String, game_number: int, selected_seed: int) -> Dictionary:
	var feature_deck: FeatureDeck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle(selected_seed)

	var game_run: GameRun = GameRun.new(feature_deck, score_trees)
	var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	random_number_generator.seed = selected_seed
	var row: Dictionary = {
		"behavior": behavior,
		"game": game_number,
		"seed": selected_seed,
		"total_selected": 0,
	}

	for release_number: int in range(1, GameRun.RELEASE_COUNT + 1):
		var selected_count: int = 0

		for _sprint_number: int in range(Release.SPRINT_COUNT):
			var sprint: Sprint = game_run.start_sprint()
			var selected_card_uids: Array[String] = _select_cards(
				sprint,
				behavior,
				random_number_generator
			)

			selected_count += selected_card_uids.size()

			for card_uid: String in selected_card_uids:
				sprint.select_card(card_uid)

			game_run.submit_sprint(sprint)

		game_run.ship_current_release()

		var release_report: ReleaseReport = game_run.get_last_release_report()
		row["r%d_fun" % release_number] = _get_report_score_delta(release_report, "Fun")
		row["r%d_money" % release_number] = _get_report_score_delta(release_report, "Money")
		row["r%d_selected" % release_number] = selected_count
		row["total_selected"] += selected_count

	row["final_fun"] = _get_game_score(game_run, "Fun")
	row["final_money"] = _get_game_score(game_run, "Money")
	row["final_combined"] = row["final_fun"] + row["final_money"]

	return row


func _select_cards(
	sprint: Sprint,
	behavior: String,
	random_number_generator: RandomNumberGenerator
) -> Array[String]:
	var feature_cards: Array[FeatureCard] = sprint.get_feature_cards()

	if behavior == "random_count":
		return _select_random_count(feature_cards, random_number_generator)

	if _is_score_behavior(behavior):
		return _select_score_target(feature_cards, behavior)

	push_error("Unsupported balance behavior: %s" % behavior)
	return _select_random_count(feature_cards, random_number_generator)


func _select_random_count(
	feature_cards: Array[FeatureCard],
	random_number_generator: RandomNumberGenerator
) -> Array[String]:
	var selected_card_uids: Array[String] = []
	var remaining_cards: Array[FeatureCard] = feature_cards.duplicate()
	var selected_count: int = random_number_generator.randi_range(1, feature_cards.size())

	for _selection_index: int in range(selected_count):
		var card_index: int = random_number_generator.randi_range(0, remaining_cards.size() - 1)
		var selected_card: FeatureCard = remaining_cards.pop_at(card_index)

		selected_card_uids.append(selected_card.get_uid())

	return selected_card_uids


func _select_score_target(feature_cards: Array[FeatureCard], behavior: String) -> Array[String]:
	var behavior_parts: PackedStringArray = behavior.split("_")
	var fun_level: String = behavior_parts[0]
	var money_level: String = behavior_parts[1]
	var best_key: Array[int] = []
	var best_card_uids: Array[String] = []

	for selection_mask: int in range(1, 8):
		var selected_cards: Array[FeatureCard] = []

		for card_index: int in range(feature_cards.size()):
			if selection_mask & (1 << card_index):
				selected_cards.append(feature_cards[card_index])

		var fun_delta: int = _calculate_cards_points(selected_cards, "Fun")
		var money_delta: int = _calculate_cards_points(selected_cards, "Money")
		var fun_fit: int = _score_axis_delta(fun_delta, fun_level)
		var money_fit: int = _score_axis_delta(money_delta, money_level)
		var key: Array[int] = [
			fun_fit + money_fit,
			min(fun_fit, money_fit),
			-abs(fun_fit - money_fit),
			-selected_cards.size(),
		]

		if best_key.is_empty() or _is_key_greater(key, best_key):
			best_key = key
			best_card_uids = _get_card_uids(selected_cards)

	return best_card_uids


func _score_axis_delta(delta: int, level: String) -> int:
	match level:
		"vh":
			return delta
		"h":
			return -abs(delta - 3)
		"m":
			return -abs(delta)
		"l":
			return -abs(delta + 3)
		"vl":
			return -delta
		_:
			return 0


func _is_score_behavior(behavior: String) -> bool:
	var behavior_parts: PackedStringArray = behavior.split("_")

	return (
		behavior_parts.size() == 2
		and SCORE_LEVELS.has(behavior_parts[0])
		and SCORE_LEVELS.has(behavior_parts[1])
	)


func _get_supported_behaviors() -> Array[String]:
	var behavior_names: Array[String] = []

	for fun_level: String in SCORE_LEVELS:
		for money_level: String in SCORE_LEVELS:
			behavior_names.append("%s_%s" % [fun_level, money_level])

	behavior_names.append(BASELINE_BEHAVIOR)

	return behavior_names


func _is_key_greater(left: Array[int], right: Array[int]) -> bool:
	for index: int in range(left.size()):
		if left[index] > right[index]:
			return true

		if left[index] < right[index]:
			return false

	return false


func _get_card_uids(feature_cards: Array[FeatureCard]) -> Array[String]:
	var card_uids: Array[String] = []

	for feature_card: FeatureCard in feature_cards:
		card_uids.append(feature_card.get_uid())

	return card_uids


func _calculate_cards_points(feature_cards: Array[FeatureCard], tree_name: String) -> int:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree
	var points: int = 0

	for feature_card: FeatureCard in feature_cards:
		for effect: FeatureEffect in feature_card.get_effects():
			if effect.get_tree_uid() != score_tree.get_uid():
				continue

			points += _calculate_effect_points(score_tree, effect)

	return points


func _calculate_effect_points(score_tree: ScoreTree, effect: FeatureEffect) -> int:
	var impact: int = 1

	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return score_tree.get_points(effect.get_node_uid()) * impact


func _get_report_score_delta(release_report: ReleaseReport, tree_name: String) -> int:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree

	return release_report.get_score_delta(score_tree.get_uid())


func _get_game_score(game_run: GameRun, tree_name: String) -> int:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree

	return game_run.get_score(score_tree.get_uid())


func _build_frequency_series(rows: Array[Dictionary]) -> Dictionary[String, Dictionary]:
	var series: Dictionary[String, Dictionary] = {}

	for row: Dictionary in rows:
		var behavior: String = row["behavior"]

		for score_tree: ScoreTree in score_trees:
			var tree_name: String = score_tree.get_display_name()
			var column_name: String = "final_%s" % tree_name.to_lower()
			var series_name: String = "%s %s" % [behavior, tree_name]
			var final_score: int = row[column_name]

			if not series.has(series_name):
				series[series_name] = {}

			series[series_name][final_score] = series[series_name].get(final_score, 0) + 1

	return series


func _format_seed_summary(
	selected_seed: int,
	is_random_seed: bool,
	game_seed_count: int
) -> String:
	if is_random_seed:
		return "Random Seeds: %d" % game_seed_count

	return "Seed: %d" % selected_seed


func _generate_deterministic_game_seeds(selected_game_count: int, selected_seed: int) -> Array[int]:
	var game_seeds: Array[int] = []

	for game_number: int in range(1, selected_game_count + 1):
		game_seeds.append(selected_seed + game_number)

	return game_seeds


func _generate_random_game_seeds(selected_game_count: int) -> Array[int]:
	var game_seeds: Array[int] = []
	var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	random_number_generator.randomize()

	for _game_number: int in range(selected_game_count):
		game_seeds.append(random_number_generator.randi_range(1, 999999999))

	return game_seeds


func _calculate_score_axis_bound() -> int:
	var strongest_node_points: int = 0

	for score_tree: ScoreTree in score_trees:
		for node: ScoreTreeNode in score_tree.nodes.values():
			if node.get_uid() == score_tree.get_root_uid():
				continue

			strongest_node_points = max(
				strongest_node_points,
				score_tree.get_points(node.get_uid())
			)

	return (
		strongest_node_points
		* GameRun.RELEASE_COUNT
		* Release.SPRINT_COUNT
		* GameRun.CARDS_PER_SPRINT
	)


func _configure_band_divider_controls() -> void:
	var band_divider_spin_boxes: Array[SpinBox] = _get_band_divider_spin_boxes()
	var score_axis_bound: int = _calculate_score_axis_bound()
	var dividers: Array[int] = _get_default_raw_score_dividers(score_axis_bound)

	for divider_index: int in range(band_divider_spin_boxes.size()):
		var spin_box: SpinBox = band_divider_spin_boxes[divider_index]

		spin_box.min_value = -score_axis_bound
		spin_box.max_value = score_axis_bound
		spin_box.value = dividers[divider_index]


func _get_default_raw_score_dividers(score_axis_bound: int) -> Array[int]:
	var dividers: Array[int] = []

	for divider_index: int in range(1, 5):
		dividers.append(int(round(
			float(-score_axis_bound)
			+ ((float(score_axis_bound * 2) / 5.0) * divider_index)
		)))

	return dividers


func _get_score_band_dividers_from_controls() -> Array[int]:
	var dividers: Array[int] = []

	for band_divider_spin_box: SpinBox in _get_band_divider_spin_boxes():
		var divider: int = int(band_divider_spin_box.value)

		if not dividers.has(divider):
			dividers.append(divider)

	dividers.sort()
	return dividers


func _get_band_divider_spin_boxes() -> Array[SpinBox]:
	return [
		band_divider_1_spin_box,
		band_divider_2_spin_box,
		band_divider_3_spin_box,
		band_divider_4_spin_box,
	]


func _write_csv(path: String, rows: Array[Dictionary]) -> void:
	var output_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)

	if output_file == null:
		push_error("Could not write balance runner results: %s" % path)
		return

	var headers: Array[String] = [
		"behavior",
		"game",
		"seed",
		"r1_fun",
		"r1_money",
		"r1_selected",
		"r2_fun",
		"r2_money",
		"r2_selected",
		"r3_fun",
		"r3_money",
		"r3_selected",
		"r4_fun",
		"r4_money",
		"r4_selected",
		"final_fun",
		"final_money",
		"final_combined",
		"total_selected",
	]

	output_file.store_line(",".join(headers))

	for row: Dictionary in rows:
		var values: PackedStringArray = []

		for header: String in headers:
			values.append(str(row.get(header, "")))

		output_file.store_line(",".join(values))

	print("Wrote balance runner results: %s" % path)
