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

	for raw_card_data: Variant in card_data:
		if not raw_card_data is Dictionary:
			push_error("Card entry must be an object.")
			continue

		var card: FeatureCard = _build_card(raw_card_data as Dictionary, score_tree_refs)

		if card == null:
			continue

		cards.append(card)

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
		cards.append_array(_load_card_data_from_file(
			path.path_join(json_file_name),
			json_file_name.get_basename()
		))

	return cards


static func _load_card_data_from_file(path: String, uid_namespace: String = "") -> Array:
	var card_uid_namespace: String = uid_namespace

	if card_uid_namespace.is_empty():
		card_uid_namespace = path.get_file().get_basename()

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

	var cards: Array = json.data as Array

	_assign_missing_card_uids(cards, card_uid_namespace)

	return cards


static func _assign_missing_card_uids(cards: Array, uid_namespace: String) -> void:
	for card_index: int in range(cards.size()):
		var raw_card_data: Variant = cards[card_index]

		if not raw_card_data is Dictionary:
			continue

		var card_data: Dictionary = raw_card_data as Dictionary
		var card_uid: String = card_data.get("uid", "")

		if not card_uid.is_empty():
			continue

		card_data["uid"] = "%s/%03d" % [uid_namespace, card_index + 1]


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
