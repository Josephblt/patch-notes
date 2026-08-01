extends CanvasLayer


const SCORE_TREE_DIR: String = "res://data/score_trees"
const BASELINE_BEHAVIOR: String = "random_count"
const NONE_BEHAVIOR: String = "none"
const RUNNER_RANDOM: String = "Random"
const DEFAULT_GAME_COUNT: int = 200
const DEFAULT_BEHAVIOR: String = "vh_vh"
const DEFAULT_SEED: int = 310731
const DEFAULT_BRANCH_POINTS: float = 3.0
const DEFAULT_LEAF_POINTS: float = 1.0
const UNBOUNDED_SCORE_MIN: float = -999999999.0
const UNBOUNDED_SCORE_MAX: float = 999999999.0
const DEFAULT_SCORE_BAND_DIVIDERS: Array[float] = [-60.0, -20.0, 20.0, 60.0]
const DEFAULT_OUTPUT_PATH: String = "user://balance_runner_results.csv"
const BEHAVIOR_MENU_CHECK_ALL_ID: int = 100000
const BEHAVIOR_MENU_CLEAR_ALL_ID: int = 100001
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
var available_runner_configs: Array[Dictionary] = []
var is_runner_active: bool = false
var stop_requested: bool = false

@export var selected_behaviors: Array[String] = [DEFAULT_BEHAVIOR]
@export var game_count: int = DEFAULT_GAME_COUNT
@export var run_seed: int = DEFAULT_SEED
@export var branch_points: float = DEFAULT_BRANCH_POINTS
@export var leaf_points: float = DEFAULT_LEAF_POINTS
@export var random_seed: bool = false
@export var output_path: String = DEFAULT_OUTPUT_PATH

@onready var behavior_menu_button: MenuButton = $MarginContainer/VBoxContainer/ControlRow/BehaviorMenuButton
@onready var game_count_spin_box: SpinBox = $MarginContainer/VBoxContainer/ControlRow/GameCountSpinBox
@onready var seed_spin_box: SpinBox = $MarginContainer/VBoxContainer/ControlRow/SeedSpinBox
@onready var random_seed_check_box: CheckBox = $MarginContainer/VBoxContainer/ControlRow/RandomSeedCheckBox
@onready var graph_dataset_1_options: OptionButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset1Options
@onready var graph_dataset_2_options: OptionButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset2Options
@onready var graph_dataset_3_options: OptionButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset3Options
@onready var graph_dataset_1_color_picker_button: ColorPickerButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset1ColorPickerButton
@onready var graph_dataset_2_color_picker_button: ColorPickerButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset2ColorPickerButton
@onready var graph_dataset_3_color_picker_button: ColorPickerButton = $MarginContainer/VBoxContainer/GraphDatasetRow/GraphDataset3ColorPickerButton
@onready var band_divider_1_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider1SpinBox
@onready var band_divider_2_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider2SpinBox
@onready var band_divider_3_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider3SpinBox
@onready var band_divider_4_spin_box: SpinBox = $MarginContainer/VBoxContainer/BandRow/BandDivider4SpinBox
@onready var branch_point_spin_box: SpinBox = $MarginContainer/VBoxContainer/PointRow/BranchPointSpinBox
@onready var leaf_point_spin_box: SpinBox = $MarginContainer/VBoxContainer/PointRow/LeafPointSpinBox
@onready var run_button: Button = $MarginContainer/VBoxContainer/ControlRow/RunButton
@onready var stop_button: Button = $MarginContainer/VBoxContainer/ControlRow/StopButton
@onready var progress_label: Label = $MarginContainer/VBoxContainer/ProgressLabel
@onready var summary_label: Label = $MarginContainer/VBoxContainer/SummaryLabel
@onready var graph: Control = $MarginContainer/VBoxContainer/Graph
@onready var main_container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var control_row: HBoxContainer = $MarginContainer/VBoxContainer/ControlRow
@onready var point_row: HBoxContainer = $MarginContainer/VBoxContainer/PointRow
@onready var band_row: HBoxContainer = $MarginContainer/VBoxContainer/BandRow
@onready var graph_dataset_row: HBoxContainer = $MarginContainer/VBoxContainer/GraphDatasetRow


func _ready() -> void:
	score_trees = ScoreTreeLoader.load_many_from_json_dir(SCORE_TREE_DIR)

	for score_tree: ScoreTree in score_trees:
		score_tree_by_name[score_tree.get_display_name()] = score_tree

	if OS.get_cmdline_user_args().size() > 0:
		_run_from_command_line()
		return

	_configure_controls()
	_order_control_rows()
	_order_control_rows_deferred()
	run_button.pressed.connect(_on_run_button_pressed)
	stop_button.pressed.connect(_on_stop_button_pressed)
	random_seed_check_box.toggled.connect(_on_random_seed_check_box_toggled)
	branch_point_spin_box.value_changed.connect(_on_level_points_changed)
	leaf_point_spin_box.value_changed.connect(_on_level_points_changed)

	for graph_dataset_options: OptionButton in _get_graph_dataset_options():
		graph_dataset_options.item_selected.connect(_on_graph_dataset_selection_changed)

	for graph_slot_color_picker: ColorPickerButton in _get_graph_slot_color_pickers():
		graph_slot_color_picker.color_changed.connect(_on_graph_slot_color_changed)

	for band_divider_spin_box: SpinBox in _get_band_divider_spin_boxes():
		band_divider_spin_box.value_changed.connect(_on_band_dividers_changed)

	_set_runner_buttons_active(false)
	summary_label.text = "Ready."


func _order_control_rows() -> void:
	main_container.move_child(point_row, control_row.get_index() + 1)
	main_container.move_child(band_row, point_row.get_index() + 1)
	main_container.move_child(graph_dataset_row, band_row.get_index() + 1)


func _order_control_rows_deferred() -> void:
	await get_tree().process_frame
	_order_control_rows()


func _run_from_command_line() -> void:
	var options: Dictionary = _parse_options()
	var rows: Array[Dictionary] = run_dataset(
		options.get("behaviors", selected_behaviors),
		options.get("games", game_count),
		options.get("seed", run_seed),
		options.get("branch_points", branch_points),
		options.get("leaf_points", leaf_points)
	)

	_write_csv(options.get("output", output_path), rows)
	get_tree().quit()


func _configure_controls() -> void:
	_configure_behavior_menu()
	_populate_graph_dataset_options([])
	_configure_unbounded_spin_box(game_count_spin_box, 1.0)
	_configure_unbounded_spin_box(seed_spin_box, 0.0)
	_configure_unbounded_spin_box(branch_point_spin_box, UNBOUNDED_SCORE_MIN, 0.1, false)
	_configure_unbounded_spin_box(leaf_point_spin_box, UNBOUNDED_SCORE_MIN, 0.1, false)
	_configure_band_divider_controls()
	game_count_spin_box.value = game_count
	seed_spin_box.value = run_seed
	branch_point_spin_box.value = branch_points
	leaf_point_spin_box.value = leaf_points
	random_seed_check_box.button_pressed = random_seed
	_apply_score_level_points(branch_points, leaf_points)
	_on_random_seed_check_box_toggled(random_seed_check_box.button_pressed)


func _configure_behavior_menu() -> void:
	var popup: PopupMenu = behavior_menu_button.get_popup()
	popup.clear()
	popup.hide_on_item_selection = false
	popup.hide_on_checkable_item_selection = false

	var item_index: int = 0
	popup.add_item("Check All", BEHAVIOR_MENU_CHECK_ALL_ID)
	item_index += 1
	popup.add_item("Clear All", BEHAVIOR_MENU_CLEAR_ALL_ID)
	item_index += 1
	popup.add_separator()
	item_index += 1

	popup.add_check_item(RUNNER_RANDOM, item_index)
	popup.set_item_metadata(item_index, BASELINE_BEHAVIOR)
	popup.set_item_checked(item_index, selected_behaviors.has(BASELINE_BEHAVIOR))
	item_index += 1

	for behavior: String in _get_score_behaviors():
		popup.add_check_item(_format_behavior_description(behavior), item_index)
		popup.set_item_metadata(item_index, behavior)
		popup.set_item_checked(item_index, selected_behaviors.has(behavior))
		item_index += 1

	if not popup.id_pressed.is_connected(_on_behavior_menu_id_pressed):
		popup.id_pressed.connect(_on_behavior_menu_id_pressed)

	_update_behavior_menu_text()


func _on_behavior_menu_id_pressed(item_id: int) -> void:
	var popup: PopupMenu = behavior_menu_button.get_popup()

	if item_id == BEHAVIOR_MENU_CHECK_ALL_ID:
		_set_all_behavior_menu_items_checked(true)
		return

	if item_id == BEHAVIOR_MENU_CLEAR_ALL_ID:
		_set_all_behavior_menu_items_checked(false)
		return

	var item_index: int = popup.get_item_index(item_id)

	if item_index < 0:
		return

	popup.set_item_checked(item_index, not popup.is_item_checked(item_index))
	_update_behavior_menu_text()
	_on_lane_visibility_changed(item_index)


func _set_all_behavior_menu_items_checked(is_checked: bool) -> void:
	var popup: PopupMenu = behavior_menu_button.get_popup()

	for item_index: int in range(popup.item_count):
		if popup.is_item_checkable(item_index):
			popup.set_item_checked(item_index, is_checked)

	_update_behavior_menu_text()
	_on_lane_visibility_changed(-1)


func _update_behavior_menu_text() -> void:
	var checked_count: int = _get_selected_behaviors().size()

	if checked_count == 1:
		behavior_menu_button.text = "1 Behavior"
	else:
		behavior_menu_button.text = "%d Behaviors" % checked_count


func _get_selected_behaviors() -> Array[String]:
	var behaviors: Array[String] = []
	var popup: PopupMenu = behavior_menu_button.get_popup()

	for item_index: int in range(popup.item_count):
		if popup.is_item_checked(item_index):
			behaviors.append(str(popup.get_item_metadata(item_index)))

	return behaviors


func _on_run_button_pressed() -> void:
	if is_runner_active:
		return

	is_runner_active = true
	stop_requested = false
	_set_runner_buttons_active(true)
	summary_label.text = "Running..."

	await get_tree().process_frame

	var behaviors: Array[String] = _get_selected_behaviors()
	var selected_game_count: int = int(game_count_spin_box.value)
	var selected_seed: int = int(seed_spin_box.value)
	var selected_branch_points: float = branch_point_spin_box.value
	var selected_leaf_points: float = leaf_point_spin_box.value
	_apply_score_level_points(selected_branch_points, selected_leaf_points)
	var selected_score_band_dividers: Array[float] = _get_score_band_dividers_from_controls()
	var game_seeds: Array[int] = []

	if random_seed_check_box.button_pressed:
		game_seeds = _generate_random_game_seeds(selected_game_count)
	else:
		game_seeds = _generate_deterministic_game_seeds(selected_game_count, selected_seed)

	available_runner_configs = _get_runner_configs(behaviors)
	var next_rows: Array[Dictionary] = await _run_dataset_with_progress(available_runner_configs, game_seeds)

	if stop_requested:
		summary_label.text = "Stopped."
		is_runner_active = false
		stop_requested = false
		_set_runner_buttons_active(false)
		return

	last_rows = next_rows
	_write_csv(output_path, last_rows)
	_populate_graph_dataset_options(available_runner_configs)
	_update_graph(selected_score_band_dividers)

	summary_label.text = _format_seed_summary(
		selected_seed,
		random_seed_check_box.button_pressed,
		game_seeds.size(),
		selected_branch_points,
		selected_leaf_points
	)
	is_runner_active = false
	_set_runner_buttons_active(false)


func _on_stop_button_pressed() -> void:
	if not is_runner_active:
		return

	stop_requested = true
	stop_button.disabled = true
	summary_label.text = "Stopping..."


func _run_dataset_with_progress(
	runner_configs: Array[Dictionary],
	game_seeds: Array[int]
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	var selected_game_count: int = game_seeds.size()
	var total_game_count: int = selected_game_count * runner_configs.size()
	var completed_game_count: int = 0

	_render_runner_progress(total_game_count, completed_game_count)
	await get_tree().process_frame

	for runner_config: Dictionary in runner_configs:
		var runner_name: String = runner_config["runner"]
		var behavior_name: String = runner_config["behavior"]

		for game_number: int in range(1, selected_game_count + 1):
			if stop_requested:
				_render_runner_progress(total_game_count, completed_game_count, "Stopped")
				return rows

			rows.append(_play_game(runner_name, behavior_name, game_number, game_seeds[game_number - 1]))
			completed_game_count += 1
			_render_runner_progress(total_game_count, completed_game_count, runner_name)
			await get_tree().process_frame

	return rows


func _set_runner_buttons_active(is_active: bool) -> void:
	run_button.disabled = is_active
	stop_button.disabled = not is_active


func _render_runner_progress(
	total_game_count: int,
	completed_game_count: int,
	current_runner_name: String = ""
) -> void:
	if total_game_count == 0:
		progress_label.text = "No behaviours selected."
		return

	var percent_complete: int = int(round(
		(float(completed_game_count) / float(total_game_count)) * 100.0
	))
	var progress_text: String = "%d/%d - %d%%" % [
		completed_game_count,
		total_game_count,
		percent_complete,
	]

	if completed_game_count >= total_game_count:
		progress_label.text = "%s | Done" % progress_text
		return

	if current_runner_name.is_empty():
		progress_label.text = progress_text
	else:
		progress_label.text = "%s | %s" % [progress_text, current_runner_name]


func _on_random_seed_check_box_toggled(is_random_seed: bool) -> void:
	seed_spin_box.editable = not is_random_seed


func _on_level_points_changed(_value: float) -> void:
	_apply_score_level_points(
		branch_point_spin_box.value,
		leaf_point_spin_box.value
	)


func _on_band_dividers_changed(_value: float) -> void:
	if last_rows.is_empty():
		return

	_update_graph()


func _on_lane_visibility_changed(_index: int) -> void:
	if last_rows.is_empty():
		return

	_update_graph()


func _on_graph_dataset_selection_changed(_index: int) -> void:
	if last_rows.is_empty():
		return

	_update_graph()


func _on_graph_slot_color_changed(_color: Color) -> void:
	_update_graph_slot_colors()

	if last_rows.is_empty():
		return

	_update_graph()


func _parse_options() -> Dictionary:
	var options: Dictionary = {
		"games": game_count,
		"behaviors": selected_behaviors.duplicate(),
		"seed": run_seed,
		"branch_points": branch_points,
		"leaf_points": leaf_points,
		"output": output_path,
	}

	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--games="):
			options["games"] = argument.trim_prefix("--games=").to_int()
		elif argument.begins_with("--behaviors="):
			options["behaviors"] = _parse_behavior_list(argument.trim_prefix("--behaviors="))
		elif argument.begins_with("--behavior="):
			var behaviors: Array[String] = options["behaviors"]
			_append_unique_behavior(behaviors, argument.trim_prefix("--behavior="))
			options["behaviors"] = behaviors
		elif argument.begins_with("--behavior2="):
			var behaviors: Array[String] = options["behaviors"]
			_append_unique_behavior(behaviors, argument.trim_prefix("--behavior2="))
			options["behaviors"] = behaviors
		elif argument.begins_with("--baseline="):
			var behaviors: Array[String] = options["behaviors"]
			_append_unique_behavior(behaviors, _parse_baseline_argument(argument.trim_prefix("--baseline=")))
			options["behaviors"] = behaviors
		elif argument.begins_with("--seed="):
			options["seed"] = argument.trim_prefix("--seed=").to_int()
		elif argument.begins_with("--branch-points="):
			options["branch_points"] = argument.trim_prefix("--branch-points=").to_float()
		elif argument.begins_with("--leaf-points="):
			options["leaf_points"] = argument.trim_prefix("--leaf-points=").to_float()
		elif argument.begins_with("--output="):
			options["output"] = argument.trim_prefix("--output=")

	return options


func _parse_behavior_list(argument_value: String) -> Array[String]:
	var behaviors: Array[String] = []

	for behavior: String in argument_value.split(",", false):
		_append_unique_behavior(behaviors, behavior.strip_edges())

	return behaviors


func _append_unique_behavior(behaviors: Array[String], behavior: String) -> void:
	if behavior == NONE_BEHAVIOR:
		return

	if behavior != BASELINE_BEHAVIOR and not _is_score_behavior(behavior):
		return

	if not behaviors.has(behavior):
		behaviors.append(behavior)


func _parse_baseline_argument(argument_value: String) -> String:
	if argument_value == RUNNER_RANDOM.to_lower() or argument_value == BASELINE_BEHAVIOR:
		return BASELINE_BEHAVIOR

	return NONE_BEHAVIOR


func run_dataset(
	behaviors: Array[String],
	selected_game_count: int,
	selected_seed: int,
	selected_branch_points: float = DEFAULT_BRANCH_POINTS,
	selected_leaf_points: float = DEFAULT_LEAF_POINTS
) -> Array[Dictionary]:
	_apply_score_level_points(selected_branch_points, selected_leaf_points)

	return _run_dataset_with_game_seeds(
		behaviors,
		_generate_deterministic_game_seeds(selected_game_count, selected_seed)
	)


func _run_dataset_with_game_seeds(
	behaviors: Array[String],
	game_seeds: Array[int]
) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	for runner_config: Dictionary in _get_runner_configs(behaviors):
		rows.append_array(_play_behavior(
			runner_config["runner"],
			runner_config["behavior"],
			game_seeds
		))

	return rows


func _get_runner_configs(behaviors: Array[String]) -> Array[Dictionary]:
	var runner_configs: Array[Dictionary] = []

	for behavior: String in behaviors:
		if behavior == NONE_BEHAVIOR:
			continue

		if behavior == BASELINE_BEHAVIOR:
			runner_configs.append({"runner": RUNNER_RANDOM, "behavior": BASELINE_BEHAVIOR})
			continue

		if not _is_score_behavior(behavior):
			continue

		runner_configs.append({
			"runner": _format_behavior_description(behavior),
			"behavior": behavior,
		})

	return runner_configs


func _play_behavior(runner: String, behavior: String, game_seeds: Array[int]) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	for game_number: int in range(1, game_seeds.size() + 1):
		rows.append(_play_game(runner, behavior, game_number, game_seeds[game_number - 1]))

	return rows


func _play_game(
	runner: String,
	behavior: String,
	game_number: int,
	selected_seed: int
) -> Dictionary:
	var feature_deck: FeatureDeck = FeatureDeckBuilder.build(score_trees)
	feature_deck.shuffle(selected_seed)

	var game_run: GameRun = GameRun.new(feature_deck, score_trees)
	var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	random_number_generator.seed = selected_seed
	var row: Dictionary = {
		"runner": runner,
		"behavior": behavior,
		"game": game_number,
		"seed": selected_seed,
		"branch_points": _get_branch_points(),
		"leaf_points": _get_leaf_points(),
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
	var best_key: Array[float] = []
	var best_card_uids: Array[String] = []

	for selection_mask: int in range(1, 8):
		var selected_cards: Array[FeatureCard] = []

		for card_index: int in range(feature_cards.size()):
			if selection_mask & (1 << card_index):
				selected_cards.append(feature_cards[card_index])

		var fun_delta: float = _calculate_cards_points(selected_cards, "Fun")
		var money_delta: float = _calculate_cards_points(selected_cards, "Money")
		var fun_fit: float = _score_axis_delta(fun_delta, fun_level)
		var money_fit: float = _score_axis_delta(money_delta, money_level)
		var key: Array[float] = [
			fun_fit + money_fit,
			min(fun_fit, money_fit),
			-abs(fun_fit - money_fit),
			-selected_cards.size(),
		]

		if best_key.is_empty() or _is_key_greater(key, best_key):
			best_key = key
			best_card_uids = _get_card_uids(selected_cards)

	return best_card_uids


func _score_axis_delta(delta: float, level: String) -> float:
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


func _format_behavior_description(behavior: String) -> String:
	var behavior_parts: PackedStringArray = behavior.split("_")

	if behavior_parts.size() != 2:
		return behavior

	var fun_level_description: String = _format_score_level_description(behavior_parts[0])
	var money_level_description: String = _format_score_level_description(behavior_parts[1])

	return "%s_|_%s" % [
		_pad_left(fun_level_description, 9, "_"),
		_pad_right(money_level_description, 9, "_"),
	]


func _pad_left(value: String, width: int, padding: String = " ") -> String:
	while value.length() < width:
		value = padding + value

	return value


func _pad_right(value: String, width: int, padding: String = " ") -> String:
	while value.length() < width:
		value += padding

	return value


func _format_score_level_description(score_level: String) -> String:
	match score_level:
		"vh":
			return "Very High"
		"h":
			return "High"
		"m":
			return "Medium"
		"l":
			return "Low"
		"vl":
			return "Very Low"
		_:
			return score_level


func _get_score_behaviors() -> Array[String]:
	var behavior_names: Array[String] = []

	for fun_level: String in SCORE_LEVELS:
		for money_level: String in SCORE_LEVELS:
			behavior_names.append("%s_%s" % [fun_level, money_level])

	return behavior_names


func _is_key_greater(left: Array[float], right: Array[float]) -> bool:
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


func _calculate_cards_points(feature_cards: Array[FeatureCard], tree_name: String) -> float:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree
	var points: float = 0.0

	for feature_card: FeatureCard in feature_cards:
		for effect: FeatureEffect in feature_card.get_effects():
			if effect.get_tree_uid() != score_tree.get_uid():
				continue

			points += _calculate_effect_points(score_tree, effect)

	return points


func _calculate_effect_points(score_tree: ScoreTree, effect: FeatureEffect) -> float:
	var impact: int = 1

	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return score_tree.get_points(effect.get_node_uid()) * impact


func _get_report_score_delta(release_report: ReleaseReport, tree_name: String) -> float:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree

	return release_report.get_score_delta(score_tree.get_uid())


func _get_game_score(game_run: GameRun, tree_name: String) -> float:
	var score_tree: ScoreTree = score_tree_by_name.get(tree_name) as ScoreTree

	return game_run.get_score(score_tree.get_uid())


func _build_frequency_series(
	rows: Array[Dictionary],
	runner_configs: Array[Dictionary] = [],
	use_runner_filter: bool = false
) -> Dictionary[String, Dictionary]:
	var series: Dictionary[String, Dictionary] = {}

	if use_runner_filter:
		for runner_config: Dictionary in runner_configs:
			for row: Dictionary in rows:
				if str(row.get("runner", row["behavior"])) != runner_config["runner"]:
					continue

				if str(row.get("behavior", "")) != runner_config["behavior"]:
					continue

				_add_row_to_frequency_series(
					series,
					row,
					"%s %s" % [runner_config["plot_slot"], runner_config["runner"]]
				)

		return series

	for row: Dictionary in rows:
		_add_row_to_frequency_series(series, row, str(row.get("runner", row["behavior"])))

	return series


func _add_row_to_frequency_series(
	series: Dictionary[String, Dictionary],
	row: Dictionary,
	series_runner_name: String
) -> void:
	for score_tree: ScoreTree in score_trees:
		var tree_name: String = score_tree.get_display_name()
		var column_name: String = "final_%s" % tree_name.to_lower()
		var series_name: String = "%s %s" % [series_runner_name, tree_name]
		var final_score_bucket: int = int(round(float(row[column_name])))

		if not series.has(series_name):
			series[series_name] = {}

		series[series_name][final_score_bucket] = (
			series[series_name].get(final_score_bucket, 0) + 1
		)


func _get_selected_runner_configs() -> Array[Dictionary]:
	var runner_configs: Array[Dictionary] = []
	var graph_dataset_options_list: Array[OptionButton] = _get_graph_dataset_options()

	for graph_dataset_index: int in range(graph_dataset_options_list.size()):
		var graph_dataset_options: OptionButton = graph_dataset_options_list[graph_dataset_index]
		if graph_dataset_options.selected < 0:
			continue

		var runner_config: Variant = graph_dataset_options.get_item_metadata(
			graph_dataset_options.selected
		)

		if not runner_config is Dictionary:
			continue

		var runner_name: String = str((runner_config as Dictionary).get("runner", ""))

		if runner_name.is_empty():
			continue

		var selected_runner_config: Dictionary = (runner_config as Dictionary).duplicate()
		selected_runner_config["plot_slot"] = "B%d" % (graph_dataset_index + 1)
		runner_configs.append(selected_runner_config)

	return runner_configs


func _populate_graph_dataset_options(runner_configs: Array[Dictionary]) -> void:
	var graph_dataset_options_list: Array[OptionButton] = _get_graph_dataset_options()

	for slot_index: int in range(graph_dataset_options_list.size()):
		var graph_dataset_options: OptionButton = graph_dataset_options_list[slot_index]
		graph_dataset_options.clear()
		graph_dataset_options.add_item(NONE_BEHAVIOR)
		graph_dataset_options.set_item_metadata(0, {})

		for runner_config: Dictionary in runner_configs:
			graph_dataset_options.add_item(runner_config["runner"])
			graph_dataset_options.set_item_metadata(graph_dataset_options.item_count - 1, runner_config)

		if slot_index + 1 < graph_dataset_options.item_count:
			graph_dataset_options.select(slot_index + 1)
		else:
			graph_dataset_options.select(0)


func _get_graph_dataset_options() -> Array[OptionButton]:
	return [
		graph_dataset_1_options,
		graph_dataset_2_options,
		graph_dataset_3_options,
	]


func _update_graph(score_band_dividers: Array[float] = []) -> void:
	var graph_dividers: Array[float] = score_band_dividers

	if graph_dividers.is_empty():
		graph_dividers = _get_score_band_dividers_from_controls()

	_update_graph_slot_colors()
	var score_axis_bound: float = _calculate_score_axis_bound()
	graph.call(
		"set_series",
		_build_frequency_series(last_rows, _get_selected_runner_configs(), true),
		-score_axis_bound,
		score_axis_bound,
		graph_dividers
	)


func _update_graph_slot_colors() -> void:
	graph.call("set_slot_colors", {
		"B1": graph_dataset_1_color_picker_button.color,
		"B2": graph_dataset_2_color_picker_button.color,
		"B3": graph_dataset_3_color_picker_button.color,
	})


func _get_graph_slot_color_pickers() -> Array[ColorPickerButton]:
	return [
		graph_dataset_1_color_picker_button,
		graph_dataset_2_color_picker_button,
		graph_dataset_3_color_picker_button,
	]


func _format_seed_summary(
	selected_seed: int,
	is_random_seed: bool,
	game_seed_count: int,
	selected_branch_points: float,
	selected_leaf_points: float
) -> String:
	var point_summary: String = "Branch: %s | Leaf: %s" % [
		_format_points(selected_branch_points),
		_format_points(selected_leaf_points),
	]

	if is_random_seed:
		return "Random Seeds: %d | %s" % [game_seed_count, point_summary]

	return "Seed: %d | %s" % [selected_seed, point_summary]


func _format_points(points: float) -> String:
	if is_equal_approx(points, round(points)):
		return str(int(round(points)))

	return "%.2f" % points


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


func _apply_score_level_points(selected_branch_points: float, selected_leaf_points: float) -> void:
	for score_tree: ScoreTree in score_trees:
		score_tree.set_points_for_level(score_tree.get_max_level() - 1, selected_branch_points)
		score_tree.set_points_for_level(score_tree.get_max_level(), selected_leaf_points)


func _get_branch_points() -> float:
	if score_trees.is_empty():
		return DEFAULT_BRANCH_POINTS

	var score_tree: ScoreTree = score_trees[0]
	return score_tree.get_points(score_tree.get_children(score_tree.get_root_uid())[0].get_uid())


func _get_leaf_points() -> float:
	if score_trees.is_empty():
		return DEFAULT_LEAF_POINTS

	var score_tree: ScoreTree = score_trees[0]
	var branch_node: ScoreTreeNode = score_tree.get_children(score_tree.get_root_uid())[0]
	return score_tree.get_points(score_tree.get_children(branch_node.get_uid())[0].get_uid())


func _calculate_score_axis_bound() -> float:
	var strongest_node_points: float = 0.0

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

	for divider_index: int in range(band_divider_spin_boxes.size()):
		var spin_box: SpinBox = band_divider_spin_boxes[divider_index]
		_configure_unbounded_spin_box(spin_box, UNBOUNDED_SCORE_MIN, 0.1, false)
		spin_box.value = DEFAULT_SCORE_BAND_DIVIDERS[divider_index]


func _configure_unbounded_spin_box(
	spin_box: SpinBox,
	minimum_value: float = UNBOUNDED_SCORE_MIN,
	step_value: float = 1.0,
	rounded_value: bool = true
) -> void:
	spin_box.allow_greater = true
	spin_box.allow_lesser = true
	spin_box.min_value = minimum_value
	spin_box.max_value = UNBOUNDED_SCORE_MAX
	spin_box.step = step_value
	spin_box.rounded = rounded_value


func _get_score_band_dividers_from_controls() -> Array[float]:
	var dividers: Array[float] = []

	for band_divider_spin_box: SpinBox in _get_band_divider_spin_boxes():
		var divider: float = band_divider_spin_box.value

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
		"runner",
		"behavior",
		"game",
		"seed",
		"branch_points",
		"leaf_points",
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
