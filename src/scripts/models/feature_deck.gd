class_name FeatureDeck
extends RefCounted

var available_cards: Array[FeatureCard]


func _init(cards: Array[FeatureCard] = []) -> void:
	available_cards = cards.duplicate()


func shuffle() -> void:
	available_cards.shuffle()


func remaining_count() -> int:
	return available_cards.size()


func has_cards() -> bool:
	return not available_cards.is_empty()


func can_draw(count: int) -> bool:
	return count >= 0 and available_cards.size() >= count


func can_draw_hand(hand_size: int = 3) -> bool:
	return can_draw(hand_size)


func draw(count: int) -> Array[FeatureCard]:
	var drawn_cards: Array[FeatureCard] = []

	if count <= 0:
		return drawn_cards

	var draw_count: int = count

	if available_cards.size() < draw_count:
		draw_count = available_cards.size()

	for index: int in range(draw_count):
		drawn_cards.append(available_cards.pop_front())

	return drawn_cards


func draw_hand(hand_size: int = 3) -> Array[FeatureCard]:
	return draw(hand_size)


func validate_unique_cards() -> Array[String]:
	var errors: Array[String] = []
	var seen_uids: Dictionary[String, bool] = {}

	for card: FeatureCard in available_cards:
		if card.uid.is_empty():
			errors.append("Deck contains a card without a uid.")
			continue

		if seen_uids.has(card.uid):
			errors.append("Deck contains duplicate card uid: %s" % card.uid)
			continue

		seen_uids[card.uid] = true

	return errors
