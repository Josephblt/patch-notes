class_name FeatureDeck
extends RefCounted


var _available_cards: Array[FeatureCard]


func _init(cards: Array[FeatureCard] = []) -> void:
	_available_cards = cards.duplicate()


func get_size() -> int:
	return _available_cards.size()


func can_draw() -> bool:
	return not _available_cards.is_empty()


func draw() -> FeatureCard:
	return _available_cards.pop_front()


func shuffle(shuffle_seed: int) -> void:
	var random_number_generator: RandomNumberGenerator = RandomNumberGenerator.new()
	random_number_generator.seed = shuffle_seed

	for card_index: int in range(_available_cards.size() - 1, 0, -1):
		var swap_index: int = random_number_generator.randi_range(0, card_index)
		var current_card: FeatureCard = _available_cards[card_index]

		_available_cards[card_index] = _available_cards[swap_index]
		_available_cards[swap_index] = current_card
