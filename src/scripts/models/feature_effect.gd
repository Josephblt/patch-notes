class_name FeatureEffect
extends RefCounted

enum Direction {
	POSITIVE,
	NEGATIVE,
}

var tree_uid: String
var node_uid: String
var direction: Direction


func _init(
	effect_tree_uid: String,
	effect_node_uid: String,
	effect_direction: Direction
) -> void:
	tree_uid = effect_tree_uid
	node_uid = effect_node_uid
	direction = effect_direction


func is_positive() -> bool:
	return direction == Direction.POSITIVE


func is_negative() -> bool:
	return direction == Direction.NEGATIVE


func get_sign() -> int:
	if is_negative():
		return -1

	return 1
