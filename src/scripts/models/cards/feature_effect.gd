class_name FeatureEffect
extends RefCounted


enum Impact {
	POSITIVE,
	NEGATIVE,
}


var _tree_uid: String
var _node_uid: String
var _impact: Impact


func _init(
	effect_tree_uid: String,
	effect_node_uid: String,
	effect_impact: Impact
) -> void:
	_tree_uid = effect_tree_uid
	_node_uid = effect_node_uid
	_impact = effect_impact


func get_tree_uid() -> String:
	return _tree_uid


func get_node_uid() -> String:
	return _node_uid


func get_impact() -> Impact:
	return _impact