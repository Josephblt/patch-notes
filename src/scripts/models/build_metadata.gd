class_name BuildMetadata
extends RefCounted


const DEFAULT_PATH: String = "res://data/build_metadata.json"
const REPOSITORY_URL: String = "https://github.com/Josephblt/patch-notes"
const UNAVAILABLE: String = "Unavailable"
const LOCAL_VERSION_LABEL: String = "Local Editor"
const LOCAL_BUILD_TYPE: String = "Local"

var version_label: String = LOCAL_VERSION_LABEL
var built_at: String = UNAVAILABLE
var build_type: String = LOCAL_BUILD_TYPE
var git_ref: String = UNAVAILABLE
var commit_sha: String = UNAVAILABLE
var short_sha: String = UNAVAILABLE
var run_number: String = UNAVAILABLE
var run_id: String = UNAVAILABLE


static func load_default() -> BuildMetadata:
	return load_from_path(DEFAULT_PATH)


static func load_from_path(metadata_path: String) -> BuildMetadata:
	var metadata := BuildMetadata.new()

	if not FileAccess.file_exists(metadata_path):
		return metadata

	var metadata_file: FileAccess = FileAccess.open(metadata_path, FileAccess.READ)
	if metadata_file == null:
		return metadata

	var parsed_metadata: Variant = JSON.parse_string(metadata_file.get_as_text())
	if not (parsed_metadata is Dictionary):
		return metadata

	metadata._load_from_dictionary(parsed_metadata)
	return metadata


func get_version_display() -> String:
	return "%s (%s)" % [version_label, short_sha]


func get_run_display() -> String:
	return "#%s (%s)" % [run_number, run_id]


func get_git_ref_url() -> String:
	if _is_unavailable(git_ref):
		return ""

	return "%s/tree/%s" % [REPOSITORY_URL, git_ref]


func get_commit_url() -> String:
	if _is_unavailable(commit_sha):
		return ""

	return "%s/commit/%s" % [REPOSITORY_URL, commit_sha]


func get_run_url() -> String:
	if _is_unavailable(run_id):
		return ""

	return "%s/actions/runs/%s" % [REPOSITORY_URL, run_id]


func _load_from_dictionary(metadata: Dictionary) -> void:
	version_label = _metadata_value(metadata, "version_label", LOCAL_VERSION_LABEL)
	built_at = _metadata_value(metadata, "built_at")
	build_type = _metadata_value(metadata, "build_type", LOCAL_BUILD_TYPE)
	git_ref = _metadata_value(metadata, "git_ref")
	commit_sha = _metadata_value(metadata, "commit_sha")
	short_sha = _metadata_value(metadata, "short_sha")
	run_number = _metadata_value(metadata, "run_number")
	run_id = _metadata_value(metadata, "run_id")


func _is_unavailable(value: String) -> bool:
	return value == UNAVAILABLE or value.strip_edges().is_empty()


func _metadata_value(metadata: Dictionary, key: String, fallback: String = UNAVAILABLE) -> String:
	var value: Variant = metadata.get(key, fallback)
	if value == null:
		return fallback

	var string_value: String = str(value).strip_edges()
	if string_value.is_empty():
		return fallback

	return string_value
