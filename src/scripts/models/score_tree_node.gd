class_name ScoreTreeNode
extends RefCounted

var uid: String
var display_name: String
var parent_uid: String
var level: int


func _init(
	node_uid: String,
	node_display_name: String,
	node_parent_uid: String,
	node_level: int
) -> void:
	uid = node_uid
	display_name = node_display_name
	parent_uid = node_parent_uid
	level = node_level


func is_root() -> bool:
	return parent_uid.is_empty()


func has_parent() -> bool:
	return not parent_uid.is_empty()
