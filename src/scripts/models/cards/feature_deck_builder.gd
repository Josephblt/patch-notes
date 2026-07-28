class_name FeatureDeckBuilder
extends RefCounted


const DEFAULT_CARD_DATA_PATH: String = "res://data/cards"


static func build(
	score_trees: Array[ScoreTree],
	card_data_path: String = DEFAULT_CARD_DATA_PATH
) -> FeatureDeck:
	var card_data: Array = _load_card_data(card_data_path)
	var score_tree_refs: Dictionary[String, Dictionary] = _build_score_tree_refs(score_trees)
	var cards: Array[FeatureCard] = []
	var effect_signatures: Dictionary[String, bool] = {}

	for raw_card_data: Variant in card_data:
		if not raw_card_data is Dictionary:
			push_error("Card entry must be an object.")
			continue

		var card: FeatureCard = _build_card(raw_card_data as Dictionary, score_tree_refs)

		if card == null:
			continue

		cards.append(card)
		effect_signatures[_build_effect_signature(card.get_effects())] = true

	_verify_card_coverage(score_trees, effect_signatures)

	return FeatureDeck.new(cards)


static func _load_card_data(path: String) -> Array:
	var dir: DirAccess = DirAccess.open(path)

	if dir != null:
		return _load_card_data_from_dir(path, dir)

	return _load_card_data_from_file(path)


static func _load_card_data_from_dir(path: String, dir: DirAccess) -> Array:
	var cards: Array = []
	var file_names: Array[String] = []

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while not file_name.is_empty():
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == "json":
			file_names.append(file_name)

		file_name = dir.get_next()

	dir.list_dir_end()
	file_names.sort()

	for json_file_name: String in file_names:
		cards.append_array(_load_card_data_from_file(path.path_join(json_file_name)))

	return cards


static func _load_card_data_from_file(path: String) -> Array:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)

	if file == null:
		push_error("Could not open card JSON file: %s" % path)
		return []

	var json_text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Could not parse card JSON file: %s. %s" % [
			path,
			json.get_error_message(),
		])
		return []

	if not json.data is Array:
		push_error("Card JSON root must be an array: %s" % path)
		return []

	return json.data as Array


static func _build_score_tree_refs(score_trees: Array[ScoreTree]) -> Dictionary[String, Dictionary]:
	var refs: Dictionary[String, Dictionary] = {}

	for score_tree: ScoreTree in score_trees:
		var nodes_by_display_name: Dictionary[String, ScoreTreeNode] = {}

		for node: ScoreTreeNode in score_tree.nodes.values():
			nodes_by_display_name[node.get_display_name()] = node

		refs[score_tree.get_display_name()] = {
			"tree": score_tree,
			"nodes": nodes_by_display_name,
		}

	return refs


static func _build_card(
	card_data: Dictionary,
	score_tree_refs: Dictionary[String, Dictionary]
) -> FeatureCard:
	var effects: Array[FeatureEffect] = _build_card_effects(card_data, score_tree_refs)

	if effects.is_empty():
		return null

	return FeatureCard.new(
		card_data.get("uid", ""),
		card_data.get("title", ""),
		card_data.get("description", ""),
		card_data.get("consequence", ""),
		effects
	)


static func _build_card_effects(
	card_data: Dictionary,
	score_tree_refs: Dictionary[String, Dictionary]
) -> Array[FeatureEffect]:
	var effects: Array[FeatureEffect] = []
	var raw_effects: Variant = card_data.get("effects", [])

	if not raw_effects is Array:
		push_error("Card effects must be an array: %s" % card_data.get("uid", ""))
		return effects

	for raw_effect: Variant in raw_effects:
		if not raw_effect is Dictionary:
			push_error("Card effect must be an object: %s" % card_data.get("uid", ""))
			continue

		var effect: FeatureEffect = _build_effect(
			raw_effect as Dictionary,
			score_tree_refs,
			card_data.get("uid", "")
		)

		if effect != null:
			effects.append(effect)

	return effects


static func _build_effect(
	effect_data: Dictionary,
	score_tree_refs: Dictionary[String, Dictionary],
	card_uid: String
) -> FeatureEffect:
	var tree_name: String = effect_data.get("tree", "")
	var node_name: String = effect_data.get("node", "")
	var impact_name: String = effect_data.get("impact", "")
	var tree_ref: Dictionary = score_tree_refs.get(tree_name, {})
	var score_tree: ScoreTree = tree_ref.get("tree") as ScoreTree
	var nodes_by_display_name: Dictionary = tree_ref.get("nodes", {})
	var node: ScoreTreeNode = nodes_by_display_name.get(node_name) as ScoreTreeNode

	if score_tree == null or node == null:
		push_error("Card effect target not found: %s" % card_uid)
		return null

	if node.get_uid() == score_tree.get_root_uid():
		push_error("Card effect cannot target root node: %s" % card_uid)
		return null

	return FeatureEffect.new(
		score_tree.get_uid(),
		node.get_uid(),
		_parse_impact(impact_name)
	)


static func _parse_impact(impact_name: String) -> FeatureEffect.Impact:
	if impact_name.to_lower() == "negative":
		return FeatureEffect.Impact.NEGATIVE

	return FeatureEffect.Impact.POSITIVE


static func _verify_card_coverage(
	score_trees: Array[ScoreTree],
	actual_signatures: Dictionary[String, bool]
) -> void:
	var expected_signatures: Dictionary[String, bool] = _build_expected_effect_signatures(score_trees)

	if actual_signatures.size() != expected_signatures.size():
		push_error("Card deck has %d effect combinations; expected %d." % [
			actual_signatures.size(),
			expected_signatures.size(),
		])
		return

	for signature: String in expected_signatures.keys():
		if not actual_signatures.has(signature):
			push_error("Card deck is missing effect combination: %s" % signature)


static func _build_expected_effect_signatures(
	score_trees: Array[ScoreTree]
) -> Dictionary[String, bool]:
	var effect_groups: Array = []

	for score_tree: ScoreTree in score_trees:
		effect_groups.append(_build_target_effects(score_tree))

	var signatures: Dictionary[String, bool] = {}

	for raw_effect_combination: Array in _build_effect_combinations(effect_groups):
		var effects: Array[FeatureEffect] = []

		for effect: FeatureEffect in raw_effect_combination:
			effects.append(effect)

		signatures[_build_effect_signature(effects)] = true

	return signatures


static func _build_target_effects(score_tree: ScoreTree) -> Array[FeatureEffect]:
	var effects: Array[FeatureEffect] = []
	var node_uids: Array[String] = []

	for node: ScoreTreeNode in score_tree.nodes.values():
		if node.get_uid() != score_tree.get_root_uid():
			node_uids.append(node.get_uid())

	node_uids.sort()

	for node_uid: String in node_uids:
		effects.append(FeatureEffect.new(
			score_tree.get_uid(),
			node_uid,
			FeatureEffect.Impact.POSITIVE
		))
		effects.append(FeatureEffect.new(
			score_tree.get_uid(),
			node_uid,
			FeatureEffect.Impact.NEGATIVE
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


static func _build_effect_signature(effects: Array[FeatureEffect]) -> String:
	var effect_parts: Array[String] = []

	for effect: FeatureEffect in effects:
		effect_parts.append("%s:%s:%d" % [
			effect.get_tree_uid(),
			effect.get_node_uid(),
			effect.get_impact(),
		])

	effect_parts.sort()
	return "|".join(effect_parts)
