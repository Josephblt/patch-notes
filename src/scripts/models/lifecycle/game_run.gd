class_name GameRun
extends RefCounted


const RELEASE_COUNT: int = 4
const CARDS_PER_SPRINT: int = 3

var _feature_deck: FeatureDeck
var _score_trees: Dictionary[String, ScoreTree]
var _scores: Dictionary[String, int]
var _releases: Array[Release]
var _current_release: Release
var _last_release_report: ReleaseReport


func _init(run_feature_deck: FeatureDeck, run_score_trees: Array[ScoreTree] = []) -> void:
	_feature_deck = run_feature_deck
	_score_trees = {}
	_scores = {}
	_releases = []
	_current_release = Release.new(1)
	_last_release_report = null
	_releases.append(_current_release)

	for score_tree: ScoreTree in run_score_trees:
		_score_trees[score_tree.get_uid()] = score_tree
		_scores[score_tree.get_uid()] = 0


func get_current_release() -> Release:
	return _current_release


func get_release_count() -> int:
	return _releases.size()


func get_score(tree_uid: String) -> int:
	return int(_scores.get(tree_uid, 0))


func get_preview_score(tree_uid: String, pending_sprint: Sprint = null) -> int:
	var preview_score: int = get_score(tree_uid)

	if _current_release != null:
		preview_score += _calculate_cards_points(
			_current_release.get_selected_cards(),
			tree_uid
		)

	if pending_sprint != null:
		preview_score += _calculate_cards_points(
			pending_sprint.get_selected_cards(),
			tree_uid
		)

	return preview_score


func get_last_release_report() -> ReleaseReport:
	return _last_release_report


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
		if not sprint.submit():
			return false

	return _current_release.add_sprint(sprint)


func ship_current_release() -> bool:
	if _current_release == null or not _current_release.ship():
		return false

	_last_release_report = _build_release_report(_current_release)
	_apply_release_scores(_last_release_report)

	if _releases.size() == RELEASE_COUNT:
		_current_release = null
		return true

	_current_release = Release.new(_releases.size() + 1)
	_releases.append(_current_release)
	return true


func _apply_release_scores(release_report: ReleaseReport) -> void:
	for score_tree_uid: String in _scores.keys():
		_scores[score_tree_uid] += release_report.get_score_delta(score_tree_uid)


func _build_release_report(release: Release) -> ReleaseReport:
	var score_deltas: Dictionary[String, int] = {}
	var selected_cards: Array[FeatureCard] = release.get_selected_cards()

	for score_tree_uid: String in _scores.keys():
		score_deltas[score_tree_uid] = _calculate_cards_points(
			selected_cards,
			score_tree_uid
		)

	return ReleaseReport.new(
		release.get_number(),
		selected_cards,
		release.get_discarded_cards(),
		score_deltas
	)


func _calculate_cards_points(cards: Array[FeatureCard], tree_uid: String) -> int:
	var points: int = 0

	for card: FeatureCard in cards:
		for effect: FeatureEffect in card.get_effects():
			if effect.get_tree_uid() != tree_uid:
				continue

			var score_tree: ScoreTree = _score_trees.get(tree_uid) as ScoreTree

			if score_tree == null:
				continue

			points += _calculate_effect_points(score_tree, effect)

	return points


func _calculate_effect_points(score_tree: ScoreTree, effect: FeatureEffect) -> int:
	var impact: int = 1

	if effect.get_impact() == FeatureEffect.Impact.NEGATIVE:
		impact = -1

	return score_tree.get_points(effect.get_node_uid()) * impact
