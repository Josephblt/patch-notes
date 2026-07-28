class_name Sprint
extends RefCounted


var _number: int
var _feature_cards: Array[FeatureCard]
var _selected_card_uids: Array[String]
var _submitted: bool


func _init(
	sprint_number: int,
	sprint_feature_cards: Array[FeatureCard] = []
) -> void:
	_number = sprint_number
	_feature_cards = sprint_feature_cards.duplicate()
	_selected_card_uids = []
	_submitted = false


func get_number() -> int:
	return _number


func get_feature_cards() -> Array[FeatureCard]:
	return _feature_cards.duplicate()


func is_submitted() -> bool:
	return _submitted


func select_card(card_uid: String) -> bool:
	if _submitted or not _has_card(card_uid) or _is_card_selected(card_uid):
		return false

	_selected_card_uids.append(card_uid)
	return true


func deselect_card(card_uid: String) -> bool:
	if _submitted or not _is_card_selected(card_uid):
		return false

	_selected_card_uids.erase(card_uid)
	return true


func get_selected_card_count() -> int:
	return _selected_card_uids.size()


func get_discarded_card_count() -> int:
	return _feature_cards.size() - _selected_card_uids.size()


func submit() -> bool:
	if _submitted:
		return false

	_submitted = true
	return true


func _has_card(card_uid: String) -> bool:
	for feature_card: FeatureCard in _feature_cards:
		if feature_card.get_uid() == card_uid:
			return true

	return false


func _is_card_selected(card_uid: String) -> bool:
	return _selected_card_uids.has(card_uid)
