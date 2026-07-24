class_name FeatureCard
extends RefCounted

var uid: String
var title: String
var description: String
var signal_text: String
var effects: Array[FeatureEffect]


func _init(
	card_uid: String,
	card_title: String,
	card_description: String,
	card_signal: String,
	card_effects: Array[FeatureEffect] = []
) -> void:
	uid = card_uid
	title = card_title
	description = card_description
	signal_text = card_signal
	effects = card_effects.duplicate()


func has_effects() -> bool:
	return not effects.is_empty()


func get_effects_for_tree(tree_uid: String) -> Array[FeatureEffect]:
	var matching_effects: Array[FeatureEffect] = []

	for effect: FeatureEffect in effects:
		if effect.tree_uid == tree_uid:
			matching_effects.append(effect)

	return matching_effects


func validate() -> Array[String]:
	var errors: Array[String] = []

	if uid.is_empty():
		errors.append("Feature card uid is required.")

	if title.is_empty():
		errors.append("Feature card title is required: %s" % uid)

	if description.is_empty():
		errors.append("Feature card description is required: %s" % uid)

	if signal_text.is_empty():
		errors.append("Feature card signal is required: %s" % uid)

	if effects.is_empty():
		errors.append("Feature card must define at least one effect: %s" % uid)

	return errors
