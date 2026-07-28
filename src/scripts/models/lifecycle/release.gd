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


func is_ready_to_ship() -> bool:
	if _sprints.size() != SPRINT_COUNT:
		return false

	for sprint: Sprint in _sprints:
		if not sprint.is_submitted():
			return false

	return true


func is_shipped() -> bool:
	return _shipped


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


func get_shipped_cards() -> Array[FeatureCard]:
	var shipped_cards: Array[FeatureCard] = []

	for sprint: Sprint in _sprints:
		shipped_cards.append_array(sprint.get_selected_cards())

	return shipped_cards


func get_discarded_cards() -> Array[FeatureCard]:
	var discarded_cards: Array[FeatureCard] = []

	for sprint: Sprint in _sprints:
		discarded_cards.append_array(sprint.get_discarded_cards())

	return discarded_cards
