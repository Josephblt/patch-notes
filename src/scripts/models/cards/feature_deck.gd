class_name FeatureDeck
extends RefCounted


var _available_cards: Array[FeatureCard]


func _init(cards: Array[FeatureCard] = []) -> void:
	_available_cards = cards.duplicate()


func shuffle() -> void:
	_available_cards.shuffle()


func has_cards() -> bool:
	return not _available_cards.is_empty()


func get_available_card_count() -> int:
	return _available_cards.size()


func draw() -> FeatureCard:
	return _available_cards.pop_front()
