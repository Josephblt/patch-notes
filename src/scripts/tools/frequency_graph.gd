extends Control
class_name FrequencyGraph


const BACKGROUND_COLOR: Color = Color(0.0901961, 0.0862745, 0.0784314, 1)
const AXIS_COLOR: Color = Color(0.48, 0.50, 0.53, 1)
const GRID_COLOR: Color = Color(0.22, 0.24, 0.25, 1)
const TEXT_COLOR: Color = Color(0.956863, 0.937255, 0.890196, 1)
const RANDOM_COLOR: Color = Color(0.29, 0.66, 0.95, 1)
const SELECTED_COLOR: Color = Color(0.95, 0.70, 0.30, 1)
const PADDING_LEFT: float = 58.0
const PADDING_TOP: float = 28.0
const PADDING_RIGHT: float = 26.0
const PADDING_BOTTOM: float = 48.0
const MIN_COMBINED_SCORE: int = -96
const MAX_COMBINED_SCORE: int = 96

var series_by_behavior: Dictionary[String, Dictionary] = {}
var min_score: int = 0
var max_score: int = 0
var max_frequency: int = 0


func set_series(next_series_by_behavior: Dictionary[String, Dictionary]) -> void:
	series_by_behavior = next_series_by_behavior
	_recalculate_bounds()
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BACKGROUND_COLOR, true)

	if series_by_behavior.is_empty():
		_draw_empty_state()
		return

	var plot_rect: Rect2 = Rect2(
		PADDING_LEFT,
		PADDING_TOP,
		max(1.0, size.x - PADDING_LEFT - PADDING_RIGHT),
		max(1.0, size.y - PADDING_TOP - PADDING_BOTTOM)
	)

	_draw_grid(plot_rect)
	_draw_axis_labels(plot_rect)
	_draw_series(plot_rect)


func _draw_empty_state() -> void:
	var font: Font = get_theme_default_font()
	var font_size: int = get_theme_default_font_size()

	draw_string(
		font,
		Vector2(24, 48),
		"Run a dataset to plot final combined score frequency.",
		HORIZONTAL_ALIGNMENT_LEFT,
		-1,
		font_size,
		TEXT_COLOR
	)


func _draw_grid(plot_rect: Rect2) -> void:
	for index: int in range(5):
		var ratio: float = float(index) / 4.0
		var y: float = plot_rect.position.y + plot_rect.size.y - (plot_rect.size.y * ratio)

		draw_line(
			Vector2(plot_rect.position.x, y),
			Vector2(plot_rect.position.x + plot_rect.size.x, y),
			GRID_COLOR,
			1.0
		)

	draw_line(
		Vector2(plot_rect.position.x, plot_rect.position.y),
		Vector2(plot_rect.position.x, plot_rect.position.y + plot_rect.size.y),
		AXIS_COLOR,
		1.5
	)
	draw_line(
		Vector2(plot_rect.position.x, plot_rect.position.y + plot_rect.size.y),
		Vector2(plot_rect.position.x + plot_rect.size.x, plot_rect.position.y + plot_rect.size.y),
		AXIS_COLOR,
		1.5
	)

	if min_score <= 0 and max_score >= 0:
		var zero_x: float = _score_to_x(0, plot_rect)
		draw_line(
			Vector2(zero_x, plot_rect.position.y),
			Vector2(zero_x, plot_rect.position.y + plot_rect.size.y),
			Color(0.60, 0.60, 0.60, 1),
			1.0
		)


func _draw_axis_labels(plot_rect: Rect2) -> void:
	var font: Font = get_theme_default_font()
	var font_size: int = 13
	var baseline_y: float = plot_rect.position.y + plot_rect.size.y + 24.0

	draw_string(font, Vector2(plot_rect.position.x - 28, plot_rect.position.y + 5), str(max_frequency), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x - 16, plot_rect.position.y + plot_rect.size.y), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x, baseline_y), str(min_score), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x + plot_rect.size.x - 30, baseline_y), str(max_score), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x + 180, baseline_y + 16), "Final combined raw score", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)

	var legend_x: float = plot_rect.position.x + plot_rect.size.x - 210.0
	var legend_y: float = plot_rect.position.y + 18.0

	_draw_legend_item(font, font_size, Vector2(legend_x, legend_y), "random_count", RANDOM_COLOR)
	_draw_legend_item(font, font_size, Vector2(legend_x, legend_y + 22.0), "selected behavior", SELECTED_COLOR)


func _draw_legend_item(font: Font, font_size: int, position: Vector2, label: String, color: Color) -> void:
	draw_line(position, position + Vector2(34, 0), color, 3.0)
	draw_string(font, position + Vector2(42, 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)


func _draw_series(plot_rect: Rect2) -> void:
	var behavior_names: Array[String] = series_by_behavior.keys()
	behavior_names.sort()

	for behavior: String in behavior_names:
		var color: Color = RANDOM_COLOR

		if behavior != "random_count":
			color = SELECTED_COLOR

		_draw_behavior_series(plot_rect, series_by_behavior[behavior], color)


func _draw_behavior_series(plot_rect: Rect2, frequencies: Dictionary, color: Color) -> void:
	var previous_point: Vector2 = Vector2.ZERO
	var has_previous_point: bool = false

	for score: int in range(min_score, max_score + 1):
		var frequency: int = frequencies.get(score, 0)
		var point: Vector2 = Vector2(
			_score_to_x(score, plot_rect),
			_frequency_to_y(frequency, plot_rect)
		)

		if has_previous_point:
			draw_line(previous_point, point, color, 2.5)

		previous_point = point
		has_previous_point = true


func _score_to_x(score: int, plot_rect: Rect2) -> float:
	if min_score == max_score:
		return plot_rect.position.x + (plot_rect.size.x / 2.0)

	return plot_rect.position.x + (
		float(score - min_score)
		/ float(max_score - min_score)
		* plot_rect.size.x
	)


func _frequency_to_y(frequency: int, plot_rect: Rect2) -> float:
	if max_frequency == 0:
		return plot_rect.position.y + plot_rect.size.y

	return plot_rect.position.y + plot_rect.size.y - (
		float(frequency)
		/ float(max_frequency)
		* plot_rect.size.y
	)


func _recalculate_bounds() -> void:
	min_score = MIN_COMBINED_SCORE
	max_score = MAX_COMBINED_SCORE
	max_frequency = 0

	for frequencies: Dictionary in series_by_behavior.values():
		for score: int in frequencies.keys():
			max_frequency = max(max_frequency, frequencies[score])
