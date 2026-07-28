class_name Sprint
extends RefCounted


const HAND_SIZE: int = 3

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


func get_card_count() -> int:
	return _feature_cards.size()


func has_full_hand() -> bool:
	return get_card_count() == HAND_SIZE


func get_selected_card_uids() -> Array[String]:
	return _selected_card_uids.duplicate()


func is_submitted() -> bool:
	return _submitted


func select_card(card_uid: String) -> bool:
	if _submitted or not _has_card(card_uid) or is_card_selected(card_uid):
		return false

	_selected_card_uids.append(card_uid)
	return true


func deselect_card(card_uid: String) -> bool:
	if _submitted or not is_card_selected(card_uid):
		return false

	_selected_card_uids.erase(card_uid)
	return true


func toggle_card_selection(card_uid: String) -> bool:
	if is_card_selected(card_uid):
		return deselect_card(card_uid)

	return select_card(card_uid)


func is_card_selected(card_uid: String) -> bool:
	return _selected_card_uids.has(card_uid)


func get_selected_cards() -> Array[FeatureCard]:
	var selected_cards: Array[FeatureCard] = []

	for feature_card: FeatureCard in _feature_cards:
		if is_card_selected(feature_card.get_uid()):
			selected_cards.append(feature_card)

	return selected_cards


func get_discarded_cards() -> Array[FeatureCard]:
	var discarded_cards: Array[FeatureCard] = []

	for feature_card: FeatureCard in _feature_cards:
		if not is_card_selected(feature_card.get_uid()):
			discarded_cards.append(feature_card)

	return discarded_cards


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
