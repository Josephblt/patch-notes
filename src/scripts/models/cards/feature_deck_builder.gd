class_name FeatureDeckBuilder
extends RefCounted


static func build(score_trees: Array[ScoreTree]) -> FeatureDeck:
	var feature_effect_groups: Array = []

	for score_tree: ScoreTree in score_trees:
		var target_effects: Array[FeatureEffect] = _build_feature_effects(score_tree)

		if target_effects.is_empty():
			push_error("Score tree has no targetable effect options: %s" % score_tree.get_uid())
			return FeatureDeck.new()

		feature_effect_groups.append(target_effects)

	var feature_effect_combinations: Array = _build_feature_effect_combinations(feature_effect_groups)
	var cards: Array[FeatureCard] = []

	for raw_effect_combination: Array in feature_effect_combinations:
		var effect_combination: Array[FeatureEffect] = []

		for effect: FeatureEffect in raw_effect_combination:
			effect_combination.append(effect)

		cards.append(_build_card(effect_combination))

	return FeatureDeck.new(cards)


static func _build_feature_effects(score_tree: ScoreTree) -> Array[FeatureEffect]:
	var feature_effects: Array[FeatureEffect] = []
	var node_uids: Array[String] = []

	for node: ScoreTreeNode in score_tree.nodes.values():
		if node.get_uid() != score_tree.get_root_uid():
			node_uids.append(node.get_uid())

	node_uids.sort()

	for node_uid: String in node_uids:
		feature_effects.append(FeatureEffect.new(
			score_tree.get_uid(),
			node_uid,
			FeatureEffect.Impact.POSITIVE
		))
		feature_effects.append(FeatureEffect.new(
			score_tree.get_uid(),
			node_uid,
			FeatureEffect.Impact.NEGATIVE
		))

	return feature_effects


static func _build_feature_effect_combinations(effect_groups: Array) -> Array:
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

	return FeatureCard.new(
		UUID.generate_v4(),
		"Generated Feature",
		"Placeholder update generated from score tree effect combinations.",
		"Placeholder consequence pending authored card copy.",
		effects
	)
