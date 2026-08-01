extends Control
class_name FrequencyGraph


const BACKGROUND_COLOR: Color = Color(0.0901961, 0.0862745, 0.0784314, 1)
const AXIS_COLOR: Color = Color(0.48, 0.50, 0.53, 1)
const GRID_COLOR: Color = Color(0.22, 0.24, 0.25, 1)
const TEXT_COLOR: Color = Color(0.956863, 0.937255, 0.890196, 1)
const BAND_COLOR: Color = Color(0.16, 0.17, 0.17, 1)
const BAND_LINE_COLOR: Color = Color(0.38, 0.39, 0.39, 1)
const SERIES_COLORS: Dictionary[String, Color] = {
	"Random Fun": Color(0.72, 0.72, 0.72, 1),
	"Random Money": Color(0.44, 0.44, 0.44, 1),
}
const PADDING_LEFT: float = 58.0
const PADDING_TOP: float = 28.0
const PADDING_RIGHT: float = 26.0
const PADDING_BOTTOM: float = 48.0

var series_by_behavior: Dictionary[String, Dictionary] = {}
var min_score: float = 0.0
var max_score: float = 0.0
var max_frequency: int = 0
var score_band_dividers: Array[float] = []


func set_series(
	next_series_by_behavior: Dictionary[String, Dictionary],
	next_min_score: float,
	next_max_score: float,
	next_score_band_dividers: Array[float] = []
) -> void:
	series_by_behavior = next_series_by_behavior
	min_score = next_min_score
	max_score = next_max_score
	score_band_dividers = next_score_band_dividers.duplicate()
	score_band_dividers.sort()
	_recalculate_max_frequency()
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

	_draw_score_bands(plot_rect)
	_draw_grid(plot_rect)
	_draw_axis_labels(plot_rect)
	_draw_series(plot_rect)


func _draw_empty_state() -> void:
	var font: Font = get_theme_default_font()
	var font_size: int = get_theme_default_font_size()

	draw_string(
		font,
		Vector2(24, 48),
		"Run a dataset to plot final Fun and Money score frequency.",
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


func _draw_score_bands(plot_rect: Rect2) -> void:
	var band_edges: Array[float] = _get_score_band_edges()

	for band_index: int in range(band_edges.size() - 1):
		if band_index % 2 != 0:
			continue

		var band_start_x: float = _score_to_x(band_edges[band_index], plot_rect)
		var band_end_x: float = _score_to_x(band_edges[band_index + 1], plot_rect)

		draw_rect(
			Rect2(
				Vector2(band_start_x, plot_rect.position.y),
				Vector2(band_end_x - band_start_x, plot_rect.size.y)
			),
			BAND_COLOR,
			true
		)

	for raw_score: float in score_band_dividers:
		var divider_x: float = _score_to_x(raw_score, plot_rect)

		draw_line(
			Vector2(divider_x, plot_rect.position.y),
			Vector2(divider_x, plot_rect.position.y + plot_rect.size.y),
			BAND_LINE_COLOR,
			1.0
		)


func _draw_axis_labels(plot_rect: Rect2) -> void:
	var font: Font = get_theme_default_font()
	var font_size: int = 13
	var baseline_y: float = plot_rect.position.y + plot_rect.size.y + 24.0

	draw_string(font, Vector2(plot_rect.position.x - 28, plot_rect.position.y + 5), str(max_frequency), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x - 16, plot_rect.position.y + plot_rect.size.y), "0", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x, baseline_y), _format_score(min_score), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x + plot_rect.size.x - 30, baseline_y), _format_score(max_score), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)
	draw_string(font, Vector2(plot_rect.position.x + 180, baseline_y + 16), "Final raw score", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)

	for raw_score: float in score_band_dividers:
		var divider_x: float = _score_to_x(raw_score, plot_rect)

		draw_string(
			font,
			Vector2(divider_x - 8.0, baseline_y),
			_format_score(raw_score),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			font_size,
			TEXT_COLOR
		)

	var legend_x: float = plot_rect.position.x + 12.0
	var legend_y: float = plot_rect.position.y + 18.0
	var behavior_names: Array[String] = _get_series_names()

	for behavior_index: int in range(behavior_names.size()):
		_draw_legend_item(
			font,
			font_size,
			Vector2(legend_x, legend_y + (behavior_index * 20.0)),
			behavior_names[behavior_index],
			_get_series_color(behavior_names[behavior_index])
		)


func _draw_legend_item(font: Font, font_size: int, position: Vector2, label: String, color: Color) -> void:
	draw_line(position, position + Vector2(34, 0), color, 3.0)
	draw_string(font, position + Vector2(42, 5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, TEXT_COLOR)


func _draw_series(plot_rect: Rect2) -> void:
	var behavior_names: Array[String] = _get_series_names()

	for behavior: String in behavior_names:

		_draw_behavior_series(
			plot_rect,
			series_by_behavior[behavior],
			_get_series_color(behavior)
		)


func _draw_behavior_series(plot_rect: Rect2, frequencies: Dictionary, color: Color) -> void:
	var previous_point: Vector2 = Vector2.ZERO
	var has_previous_point: bool = false
	var min_bucket: int = floori(min_score)
	var max_bucket: int = ceili(max_score)

	for score_bucket: int in range(min_bucket, max_bucket + 1):
		var frequency: int = frequencies.get(score_bucket, 0)
		var point: Vector2 = Vector2(
			_score_to_x(float(score_bucket), plot_rect),
			_frequency_to_y(frequency, plot_rect)
		)

		if has_previous_point:
			draw_line(previous_point, point, color, 2.5)

		previous_point = point
		has_previous_point = true


func _score_to_x(score: float, plot_rect: Rect2) -> float:
	if min_score == max_score:
		return plot_rect.position.x + (plot_rect.size.x / 2.0)

	return plot_rect.position.x + (
		float(score - min_score)
		/ float(max_score - min_score)
		* plot_rect.size.x
	)


func _get_score_band_edges() -> Array[float]:
	var band_edges: Array[float] = [min_score]

	for divider: float in score_band_dividers:
		if divider > min_score and divider < max_score:
			band_edges.append(divider)

	band_edges.append(max_score)
	return band_edges


func _frequency_to_y(frequency: int, plot_rect: Rect2) -> float:
	if max_frequency == 0:
		return plot_rect.position.y + plot_rect.size.y

	return plot_rect.position.y + plot_rect.size.y - (
		float(frequency)
		/ float(max_frequency)
		* plot_rect.size.y
	)


func _get_series_names() -> Array[String]:
	var series_names: Array[String] = series_by_behavior.keys()
	series_names.sort()
	return series_names


func _get_series_color(series_name: String) -> Color:
	if SERIES_COLORS.has(series_name):
		return SERIES_COLORS[series_name]

	var base_name: String = _get_series_base_name(series_name)
	var hue: float = float(abs(base_name.hash()) % 360) / 360.0
	var value: float = 0.92

	if series_name.ends_with(" Money"):
		value = 0.62

	return Color.from_hsv(hue, 0.74, value, 1.0)


func _get_series_base_name(series_name: String) -> String:
	if series_name.ends_with(" Fun"):
		return series_name.substr(0, series_name.length() - 4)

	if series_name.ends_with(" Money"):
		return series_name.substr(0, series_name.length() - 6)

	return series_name


func _format_score(score: float) -> String:
	if is_equal_approx(score, round(score)):
		return str(int(round(score)))

	return "%.2f" % score


func _recalculate_max_frequency() -> void:
	max_frequency = 0

	for frequencies: Dictionary in series_by_behavior.values():
		for score: int in frequencies.keys():
			max_frequency = max(max_frequency, frequencies[score])
