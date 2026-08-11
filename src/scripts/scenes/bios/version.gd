class_name BiosVersion
extends BiosItem


@onready var _version_label: Label = $VersionLeftVBoxContainer/VersionLine3
@onready var _built_at_label: Label = $VersionLeftVBoxContainer/VersionLine4
@onready var _build_type_label: Label = $VersionLeftVBoxContainer/VersionLine5
@onready var _build_channel_label: Label = $VersionLeftVBoxContainer/VersionLine6
@onready var _git_ref_label: Label = $VersionLeftVBoxContainer/VersionLine7
@onready var _commit_label: Label = $VersionLeftVBoxContainer/VersionLine8
@onready var _run_label: Label = $VersionLeftVBoxContainer/VersionLine9


func _ready() -> void:
	var metadata: BuildMetadata = BuildMetadata.load_default()

	_version_label.text = "    Version: %s" % metadata.get_version_display()
	_built_at_label.text = "    Built At: %s" % metadata.built_at
	_build_type_label.text = "    Build Type: %s" % metadata.build_type
	_build_channel_label.text = "    Channel: %s" % metadata.build_channel
	_git_ref_label.text = "    Git Ref: %s" % metadata.git_ref
	_commit_label.text = "    Commit: %s" % metadata.commit_sha
	_run_label.text = "    Run: %s" % metadata.get_run_display()
