class_name FeatureDeckBuilder
extends RefCounted

const POSITIVE_LABEL := "positive"
const NEGATIVE_LABEL := "negative"


static func build_from_score_trees(score_trees: Array[ScoreTree]) -> FeatureDeck:
	var effect_groups: Array = []

	for score_tree: ScoreTree in score_trees:
		var target_effects: Array[FeatureEffect] = _build_target_effects(score_tree)

		if target_effects.is_empty():
			push_error("Score tree has no targetable effect options: %s" % score_tree.uid)
			return FeatureDeck.new()

		effect_groups.append(target_effects)

	var effect_combinations: Array = _build_effect_combinations(effect_groups)
	var cards: Array[FeatureCard] = []

	for raw_effect_combination: Array in effect_combinations:
		var effect_combination: Array[FeatureEffect] = []

		for effect: FeatureEffect in raw_effect_combination:
			effect_combination.append(effect)

		cards.append(_build_card(effect_combination))

	return FeatureDeck.new(cards)


static func build_from_score_tree_dir(path: String) -> FeatureDeck:
	return build_from_score_trees(ScoreTree.load_many_from_json_dir(path))


static func _build_target_effects(score_tree: ScoreTree) -> Array[FeatureEffect]:
	var effects: Array[FeatureEffect] = []

	for node: ScoreTreeNode in score_tree.get_targetable_nodes():
		effects.append(FeatureEffect.new(
			score_tree.uid,
			node.uid,
			FeatureEffect.Direction.POSITIVE
		))
		effects.append(FeatureEffect.new(
			score_tree.uid,
			node.uid,
			FeatureEffect.Direction.NEGATIVE
		))

	return effects


static func _build_effect_combinations(effect_groups: Array) -> Array:
	var combinations: Array = [[]]

	for effect_group: Array in effect_groups:
		var next_combinations: Array = []

		for combination: Array in combinations:
			for effect: FeatureEffect in effect_group:
				var next_combination: Array = combination.duplicate()
				next_combination.append(effect)
				next_combinations.append(next_combination)

		combinations = next_combinations

	return combinations


static func _build_card(effects: Array[FeatureEffect]) -> FeatureCard:
	var uid: String = _build_card_uid(effects)

	return FeatureCard.new(
		uid,
		"Generated Feature",
		"Placeholder update generated from score tree effect combinations.",
		"Placeholder consequence pending authored card copy.",
		effects
	)


static func _build_card_uid(effects: Array[FeatureEffect]) -> String:
	var parts: Array[String] = []

	for effect: FeatureEffect in effects:
		parts.append("%s:%s:%s" % [
			effect.tree_uid,
			effect.node_uid,
			_get_direction_label(effect.direction),
		])

	parts.sort()

	var card_uid: String = "generated-card"

	for part: String in parts:
		card_uid = "%s|%s" % [card_uid, part]

	return card_uid


static func _get_direction_label(direction: FeatureEffect.Direction) -> String:
	if direction == FeatureEffect.Direction.NEGATIVE:
		return NEGATIVE_LABEL

	return POSITIVE_LABEL
