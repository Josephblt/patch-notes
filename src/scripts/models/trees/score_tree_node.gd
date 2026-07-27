class_name ScoreTreeNode
extends RefCounted

var _uid: String
var _display_name: String
var _parent_uid: String
var _level: int


func _init(
	node_uid: String,
	node_display_name: String,
	node_parent_uid: String,
	node_level: int
) -> void:
	_uid = node_uid
	_display_name = node_display_name
	_parent_uid = node_parent_uid
	_level = node_level


func get_uid() -> String:
	return _uid


func get_display_name() -> String:
	return _display_name


func get_parent_uid() -> String:
	return _parent_uid


func get_level() -> int:
	return _level


func is_root() -> bool:
	return not has_parent()


func has_parent() -> bool:
	return not _parent_uid.is_empty()
