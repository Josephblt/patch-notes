class_name FeatureCard
extends RefCounted


var _uid: String
var _title: String
var _description: String
var _consequence: String
var _effects: Array[FeatureEffect]


func _init(
	card_uid: String,
	card_title: String,
	card_description: String,
	card_consequence: String,
	card_effects: Array[FeatureEffect] = []
) -> void:
	_uid = card_uid
	_title = card_title
	_description = card_description
	_consequence = card_consequence
	_effects = card_effects.duplicate()


func get_uid() -> String:
	return _uid


func get_title() -> String:
	return _title


func get_description() -> String:
	return _description


func get_consequence() -> String:
	return _consequence


func get_effects() -> Array[FeatureEffect]:
	return _effects.duplicate()
