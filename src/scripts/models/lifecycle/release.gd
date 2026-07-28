class_name Release
extends RefCounted


const SPRINT_COUNT: int = 4

var _number: int
var _sprints: Array[Sprint]
var _shipped: bool


func _init(release_number: int) -> void:
	_number = release_number
	_sprints = []
	_shipped = false


func get_number() -> int:
	return _number


func get_sprint_count() -> int:
	return _sprints.size()


func is_ready_to_ship() -> bool:
	if _sprints.size() != SPRINT_COUNT:
		return false

	for sprint: Sprint in _sprints:
		if not sprint.is_submitted():
			return false

	return true


func is_shipped() -> bool:
	return _shipped


func get_selected_card_count() -> int:
	var selected_card_count: int = 0

	for sprint: Sprint in _sprints:
		selected_card_count += sprint.get_selected_card_count()

	return selected_card_count


func get_selected_cards() -> Array[FeatureCard]:
	var selected_cards: Array[FeatureCard] = []

	for sprint: Sprint in _sprints:
		selected_cards.append_array(sprint.get_selected_cards())

	return selected_cards


func get_discarded_card_count() -> int:
	var discarded_card_count: int = 0

	for sprint: Sprint in _sprints:
		discarded_card_count += sprint.get_discarded_card_count()

	return discarded_card_count


func add_sprint(sprint: Sprint) -> bool:
	if _shipped or _sprints.size() == SPRINT_COUNT or sprint == null:
		return false

	_sprints.append(sprint)
	return true


func ship() -> bool:
	if _shipped or not is_ready_to_ship():
		return false

	_shipped = true
	return true
