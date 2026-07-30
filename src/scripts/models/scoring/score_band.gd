class_name ScoreBand
extends RefCounted


var uid: String
var display_name: String
var min_score: int
var max_score: int


func _init(
	band_uid: String,
	band_display_name: String,
	band_min_score: int,
	band_max_score: int
) -> void:
	uid = band_uid
	display_name = band_display_name
	min_score = band_min_score
	max_score = band_max_score


func contains(score: int) -> bool:
	return score >= min_score and score <= max_score


func get_uid() -> String:
	return uid


func get_display_name() -> String:
	return display_name
