class_name FeatureDeckBuilder
extends RefCounted


static func build(score_trees: Array[ScoreTree]) -> FeatureDeck:
	var feature_effect_groups: Array = []
	var score_trees_by_uid: Dictionary[String, ScoreTree] = {}

	for score_tree: ScoreTree in score_trees:
		score_trees_by_uid[score_tree.get_uid()] = score_tree

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

		cards.append(_build_card(effect_combination, score_trees_by_uid))

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


static func _build_card(
	effects: Array[FeatureEffect],
	score_trees_by_uid: Dictionary[String, ScoreTree]
) -> FeatureCard:
	var title: String = "UNSCOPED UPDATE"
	var description: String = "A proposed change arrived without enough context to make anyone comfortable."
	var consequence: String = "The meeting approved it after changing the subject twice."
	var fun_effect: FeatureEffect = _find_effect_for_tree(effects, "Fun", score_trees_by_uid)
	var money_effect: FeatureEffect = _find_effect_for_tree(effects, "Money", score_trees_by_uid)

	if fun_effect != null and money_effect != null:
		var fun_copy: Dictionary[String, String] = _build_effect_copy(
			fun_effect,
			score_trees_by_uid
		)
		var money_copy: Dictionary[String, String] = _build_effect_copy(
			money_effect,
			score_trees_by_uid
		)
		title = _build_card_title(fun_effect, money_effect, score_trees_by_uid)
		description = "%s %s" % [
			fun_copy["description"],
			money_copy["description"],
		]
		consequence = "%s %s" % [
			fun_copy["consequence"],
			money_copy["consequence"],
		]

	return FeatureCard.new(
		UUID.generate_v4(),
		title,
		description,
		consequence,
		effects
	)


static func _find_effect_for_tree(
	effects: Array[FeatureEffect],
	tree_display_name: String,
	score_trees_by_uid: Dictionary[String, ScoreTree]
) -> FeatureEffect:
	for effect: FeatureEffect in effects:
		var score_tree: ScoreTree = score_trees_by_uid.get(effect.get_tree_uid()) as ScoreTree

		if score_tree != null and score_tree.get_display_name() == tree_display_name:
			return effect

	return null


static func _build_effect_copy(
	effect: FeatureEffect,
	score_trees_by_uid: Dictionary[String, ScoreTree]
) -> Dictionary[String, String]:
	var score_tree: ScoreTree = score_trees_by_uid.get(effect.get_tree_uid()) as ScoreTree
	var node: ScoreTreeNode = score_tree.get_node(effect.get_node_uid())
	var node_name: String = node.get_display_name()
	var is_positive: bool = effect.get_impact() == FeatureEffect.Impact.POSITIVE

	if score_tree.get_display_name() == "Fun":
		return _build_fun_copy(node_name, is_positive)

	return _build_money_copy(node_name, is_positive)


static func _build_card_title(
	fun_effect: FeatureEffect,
	money_effect: FeatureEffect,
	score_trees_by_uid: Dictionary[String, ScoreTree]
) -> String:
	return "%s %s UPDATE" % [
		_build_title_token(fun_effect, score_trees_by_uid),
		_build_title_token(money_effect, score_trees_by_uid),
	]


static func _build_title_token(
	effect: FeatureEffect,
	score_trees_by_uid: Dictionary[String, ScoreTree]
) -> String:
	var score_tree: ScoreTree = score_trees_by_uid.get(effect.get_tree_uid()) as ScoreTree
	var node: ScoreTreeNode = score_tree.get_node(effect.get_node_uid())
	var node_name: String = node.get_display_name()
	var is_positive: bool = effect.get_impact() == FeatureEffect.Impact.POSITIVE

	if score_tree.get_display_name() == "Fun":
		if node_name == "Experience":
			if is_positive:
				return "POLISHED"

			return "DELIBERATE"

		if node_name == "Feel":
			if is_positive:
				return "RESPONSIVE"

			return "WEIGHTY"

		if node_name == "Clarity":
			if is_positive:
				return "READABLE"

			return "STREAMLINED"

		if node_name == "Attachment":
			if is_positive:
				return "IDENTITY"

			return "RESET"

		if node_name == "Meaning":
			if is_positive:
				return "LORE"

			return "CONDENSED"

		if is_positive:
			return "PROMISE"

		return "ROADMAP"

	if node_name == "Revenue":
		if is_positive:
			return "PREMIUM"

		return "GOODWILL"

	if node_name == "Spending":
		if is_positive:
			return "COSMETIC"

		return "LOW-PRESSURE"

	if node_name == "Conversion":
		if is_positive:
			return "FUNNEL"

		return "DIRECT"

	if node_name == "Growth":
		if is_positive:
			return "BROADCAST"

		return "NICHE"

	if node_name == "Reach":
		if is_positive:
			return "CREATOR"

		return "QUALITY"

	if is_positive:
		return "DAILY"

	return "RESPECT"


static func _build_fun_copy(node_name: String, is_positive: bool) -> Dictionary[String, String]:
	if node_name == "Experience":
		if is_positive:
			return {
				"title": "CORE LOOP POLISH PASS",
				"description": "Moment-to-moment play has been tuned until the verbs stop fighting the player.",
				"consequence": "For once, the patch note uses the word \"responsive\" and means it.",
			}

		return {
			"title": "MEANINGFUL FRICTION UPDATE",
			"description": "Common actions now take extra confirmation steps to emphasize commitment.",
			"consequence": "The game has become more deliberate, mostly while opening doors.",
		}

	if node_name == "Feel":
		if is_positive:
			return {
				"title": "INPUT FEEL PASS",
				"description": "Animation timing and combat response have been adjusted for cleaner player control.",
				"consequence": "Players report that missed dodges now feel personally earned.",
			}

		return {
			"title": "WEIGHTIER INTERACTIONS",
			"description": "Movement and crafting now include additional delay to communicate physical presence.",
			"consequence": "Every button press arrives with a small lecture about mass.",
		}

	if node_name == "Clarity":
		if is_positive:
			return {
				"title": "READABLE SYSTEMS PASS",
				"description": "Quest markers, tooltips, and ability text have been revised for faster comprehension.",
				"consequence": "Several mysteries were reclassified as user interface defects.",
			}

		return {
			"title": "STREAMLINED TOOLTIP STRATEGY",
			"description": "Several tutorial prompts have been removed to reduce early-session interruption.",
			"consequence": "Players now reach confusion faster and with fewer clicks.",
		}

	if node_name == "Attachment":
		if is_positive:
			return {
				"title": "PLAYER IDENTITY PASS",
				"description": "Long-term goals now reflect the character a player has actually been building.",
				"consequence": "The save file has started looking less like rented furniture.",
			}

		return {
			"title": "SEASONAL RESET ALIGNMENT",
			"description": "Progression has been flattened so each new season starts from a cleaner baseline.",
			"consequence": "Veterans received a fresh start, which is what the meeting called losing everything.",
		}

	if node_name == "Meaning":
		if is_positive:
			return {
				"title": "LORE PAYOFF UPDATE",
				"description": "Faction choices now unlock small story reactions instead of only currency bundles.",
				"consequence": "The world briefly remembers what the player did to it.",
			}

		return {
			"title": "NARRATIVE EFFICIENCY PASS",
			"description": "Optional story beats have been condensed to keep players closer to the reward track.",
			"consequence": "The kingdom's grief now fits neatly between two upgrade prompts.",
		}

	if is_positive:
		return {
			"title": "PROMISE DEBT CLEANUP",
			"description": "Several long-advertised fixes have finally shipped with plain wording and no bundle attached.",
			"consequence": "Players reacted poorly to having nothing obvious to distrust.",
		}

	return {
		"title": "EXPECTATION MANAGEMENT UPDATE",
		"description": "Previously announced features have been reframed as aspirational pillars.",
		"consequence": "The roadmap survived by becoming less related to roads.",
	}


static func _build_money_copy(node_name: String, is_positive: bool) -> Dictionary[String, String]:
	if node_name == "Revenue":
		if is_positive:
			return {
				"title": "PREMIUM VALUE REALIGNMENT",
				"description": "Optional purchases have been reorganized around clearer upgrade ladders.",
				"consequence": "The economy now explains itself mainly through prices.",
			}

		return {
			"title": "GOODWILL PRICING PASS",
			"description": "Several paid conveniences have been moved into the base progression path.",
			"consequence": "Revenue meetings became shorter and more pointed.",
		}

	if node_name == "Spending":
		if is_positive:
			return {
				"title": "EXPANDED COSMETIC LADDER",
				"description": "The outfit catalog now includes prestige variants, bundle tiers, and matching effects.",
				"consequence": "Self-expression gained three currencies and a launch discount.",
			}

		return {
			"title": "REDUCED PURCHASE PRESSURE",
			"description": "Limited-time store labels have been softened across the event interface.",
			"consequence": "Players felt less hunted. The dashboard noticed.",
		}

	if node_name == "Conversion":
		if is_positive:
			return {
				"title": "OPTIMIZED STORE RETURN PATH",
				"description": "Closing the shop now returns players to a curated offer instead of the previous screen.",
				"consequence": "The back button has been promoted to a strategic revenue surface.",
			}

		return {
			"title": "STORE DETOUR REMOVAL",
			"description": "Upgrade prompts now return players directly to play after they decline.",
			"consequence": "The funnel became more humane and less like a corridor with sales banners.",
		}

	if node_name == "Growth":
		if is_positive:
			return {
				"title": "AUDIENCE EXPANSION PACKAGE",
				"description": "Early quests have been reshaped to appeal to players outside the existing niche.",
				"consequence": "The game now waves at people who have never read a crafting spreadsheet.",
			}

		return {
			"title": "NICHE DEPTH SPRINT",
			"description": "New systems favor experienced players who already understand the existing mess.",
			"consequence": "The target audience got narrower, louder, and easier to find in comment threads.",
		}

	if node_name == "Reach":
		if is_positive:
			return {
				"title": "CREATOR MOMENT TOOLKIT",
				"description": "New encounters now produce cleaner clips, sharper reactions, and fewer dead-air explanations.",
				"consequence": "Marketing discovered a feature it could understand without a meeting.",
			}

		return {
			"title": "QUIET QUALITY PATCH",
			"description": "Several improvements target stability and polish instead of visible launch beats.",
			"consequence": "The game got better in ways that make terrible thumbnails.",
		}

	if is_positive:
		return {
			"title": "DAILY MOMENTUM SYSTEM",
			"description": "Players now receive escalating rewards for checking in across consecutive days.",
			"consequence": "The calendar has been invited to join the core loop.",
		}

	return {
		"title": "SESSION RESPECT UPDATE",
		"description": "Daily requirements have been shortened so players can leave before resentment sets in.",
		"consequence": "Engagement dipped, but so did the number of goodbye essays.",
	}
