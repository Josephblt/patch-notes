class_name ScoreInterpreter
extends RefCounted


const FINAL_MIN_RAW_SCORE: int = -72
const FINAL_MAX_RAW_SCORE: int = 72
const RELEASE_MIN_RAW_DELTA: int = -30
const RELEASE_MAX_RAW_DELTA: int = 30
const DEFAULT_SCORE_BANDS_PATH: String = "res://data/scoring/final_score_bands.json"
const DEFAULT_FINAL_RESULTS_PATH: String = "res://data/scoring/final_results.json"
const DEFAULT_RELEASE_UPDATES_PATH: String = "res://data/scoring/release_updates.json"

var _score_bands: Array[ScoreBand]
var _final_results: Array[Dictionary]
var _release_updates: Array[Dictionary]


func _init(
	score_bands: Array[ScoreBand] = [],
	final_results: Array[Dictionary] = [],
	release_updates: Array[Dictionary] = []
) -> void:
	_score_bands = score_bands.duplicate()
	_final_results = final_results.duplicate()
	_release_updates = release_updates.duplicate()


static func load_default() -> ScoreInterpreter:
	return ScoreInterpreter.new(
		_load_score_bands(DEFAULT_SCORE_BANDS_PATH),
		_load_dictionary_array(DEFAULT_FINAL_RESULTS_PATH),
		_load_dictionary_array(DEFAULT_RELEASE_UPDATES_PATH)
	)


func evaluate_final_scores(fun_raw_score: float, money_raw_score: float) -> Dictionary:
	var fun_normalized: int = normalize(
		fun_raw_score,
		FINAL_MIN_RAW_SCORE,
		FINAL_MAX_RAW_SCORE
	)
	var money_normalized: int = normalize(
		money_raw_score,
		FINAL_MIN_RAW_SCORE,
		FINAL_MAX_RAW_SCORE
	)
	var fun_band: ScoreBand = get_band(fun_normalized)
	var money_band: ScoreBand = get_band(money_normalized)

	return {
		"fun_raw_score": fun_raw_score,
		"money_raw_score": money_raw_score,
		"fun_normalized_score": fun_normalized,
		"money_normalized_score": money_normalized,
		"fun_band": fun_band,
		"money_band": money_band,
		"result": _find_result(_final_results, fun_band, money_band),
	}


func evaluate_release_delta(fun_raw_delta: float, money_raw_delta: float) -> Dictionary:
	var fun_normalized: int = normalize(
		fun_raw_delta,
		RELEASE_MIN_RAW_DELTA,
		RELEASE_MAX_RAW_DELTA
	)
	var money_normalized: int = normalize(
		money_raw_delta,
		RELEASE_MIN_RAW_DELTA,
		RELEASE_MAX_RAW_DELTA
	)
	var fun_band: ScoreBand = get_band(fun_normalized)
	var money_band: ScoreBand = get_band(money_normalized)

	return {
		"fun_raw_delta": fun_raw_delta,
		"money_raw_delta": money_raw_delta,
		"fun_normalized_delta": fun_normalized,
		"money_normalized_delta": money_normalized,
		"fun_band": fun_band,
		"money_band": money_band,
		"update": _find_result(_release_updates, fun_band, money_band),
	}


func normalize(raw_score: float, min_raw_score: float, max_raw_score: float) -> int:
	var clamped_score: float = clampf(raw_score, min_raw_score, max_raw_score)
	var raw_range: float = max_raw_score - min_raw_score

	if raw_range <= 0.0:
		return 0

	return int(round(((clamped_score - min_raw_score) / raw_range) * 100.0))


func get_band(normalized_score: int) -> ScoreBand:
	var clamped_score: int = clampi(normalized_score, 0, 100)

	for score_band: ScoreBand in _score_bands:
		if score_band.contains(clamped_score):
			return score_band

	return null


func _find_result(
	results: Array[Dictionary],
	fun_band: ScoreBand,
	money_band: ScoreBand
) -> Dictionary:
	if fun_band == null or money_band == null:
		return {}

	for result: Dictionary in results:
		if (
			result.get("fun_band", "") == fun_band.get_uid()
			and result.get("money_band", "") == money_band.get_uid()
		):
			return result.duplicate()

	return {}


static func _load_score_bands(path: String) -> Array[ScoreBand]:
	var raw_bands: Array[Dictionary] = _load_dictionary_array(path)
	var score_bands: Array[ScoreBand] = []

	for raw_band: Dictionary in raw_bands:
		score_bands.append(ScoreBand.new(
			raw_band.get("uid", ""),
			raw_band.get("display_name", ""),
			raw_band.get("min_score", 0),
			raw_band.get("max_score", 0)
		))

	return score_bands


static func _load_dictionary_array(path: String) -> Array[Dictionary]:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	var dictionaries: Array[Dictionary] = []

	if file == null:
		push_error("Could not open scoring JSON file: %s" % path)
		return dictionaries

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(file.get_as_text())

	if parse_result != OK:
		push_error("Could not parse scoring JSON file: %s. %s" % [
			path,
			json.get_error_message(),
		])
		return dictionaries

	if not json.data is Array:
		push_error("Scoring JSON root must be an array: %s" % path)
		return dictionaries

	var items: Array = json.data as Array

	for item: Variant in items:
		if not item is Dictionary:
			push_error("Scoring JSON item must be an object: %s" % path)
			continue

		dictionaries.append(item as Dictionary)

	return dictionaries
