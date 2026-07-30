class_name ReleaseReport
extends RefCounted


var _release_number: int
var _shipped_cards: Array[FeatureCard]
var _discarded_cards: Array[FeatureCard]
var _score_deltas: Dictionary[String, int]


func _init(
	report_release_number: int,
	report_shipped_cards: Array[FeatureCard] = [],
	report_discarded_cards: Array[FeatureCard] = [],
	report_score_deltas: Dictionary[String, int] = {}
) -> void:
	_release_number = report_release_number
	_shipped_cards = report_shipped_cards.duplicate()
	_discarded_cards = report_discarded_cards.duplicate()
	_score_deltas = report_score_deltas.duplicate()


func get_release_number() -> int:
	return _release_number


func get_shipped_cards() -> Array[FeatureCard]:
	return _shipped_cards.duplicate()


func get_discarded_cards() -> Array[FeatureCard]:
	return _discarded_cards.duplicate()


func get_score_delta(tree_uid: String) -> int:
	return int(_score_deltas.get(tree_uid, 0))
