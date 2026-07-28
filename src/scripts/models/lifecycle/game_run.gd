class_name GameRun
extends RefCounted


const RELEASE_COUNT: int = 4
const CARDS_PER_SPRINT: int = 3

var _feature_deck: FeatureDeck
var _releases: Array[Release]
var _current_release: Release


func _init(run_feature_deck: FeatureDeck) -> void:
	_feature_deck = run_feature_deck
	_releases = []
	_current_release = Release.new(1)
	_releases.append(_current_release)


func get_current_release() -> Release:
	return _current_release


func get_release_count() -> int:
	return _releases.size()


func start_sprint() -> Sprint:
	if _current_release == null or _current_release.is_ready_to_ship():
		return null

	if _feature_deck == null or _feature_deck.get_size() < CARDS_PER_SPRINT:
		return null

	var sprint_cards: Array[FeatureCard] = []

	for _card_index: int in range(CARDS_PER_SPRINT):
		sprint_cards.append(_feature_deck.draw())

	return Sprint.new(_current_release.get_sprint_count() + 1, sprint_cards)


func submit_sprint(sprint: Sprint) -> bool:
	if sprint == null or _current_release == null or _current_release.is_ready_to_ship():
		return false

	if not sprint.is_submitted():
		sprint.submit()

	return _current_release.add_sprint(sprint)


func ship_current_release() -> bool:
	if _current_release == null or not _current_release.ship():
		return false

	if _releases.size() == RELEASE_COUNT:
		_current_release = null
		return true

	_current_release = Release.new(_releases.size() + 1)
	_releases.append(_current_release)
	return true
