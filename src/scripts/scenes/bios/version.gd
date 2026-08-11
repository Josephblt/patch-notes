class_name BiosVersion
extends BiosItem


@onready var _version_label: Label = %VersionLine3
@onready var _built_at_label: Label = %BuiltAtLine4
@onready var _build_type_label: Label = %BuildTypeLine5
@onready var _git_ref_link: LinkButton = %GitRefLine6
@onready var _commit_link: LinkButton = %CommitLine7
@onready var _run_link: LinkButton = %RunLine8


func _ready() -> void:
	var metadata: BuildMetadata = BuildMetadata.load_default()

	_version_label.text = "    Version: %s" % metadata.get_version_display()
	_built_at_label.text = "    Built At: %s" % metadata.built_at
	_build_type_label.text = "    Build Type: %s" % metadata.build_type
	_set_metadata_link(_git_ref_link, "%s" % metadata.git_ref, metadata.get_git_ref_url())
	_set_metadata_link(_commit_link, "%s" % metadata.commit_sha, metadata.get_commit_url())
	_set_metadata_link(_run_link, "%s" % metadata.get_run_display(), metadata.get_run_url())


func _set_metadata_link(link_button: LinkButton, link_text: String, link_uri: String) -> void:
	link_button.text = link_text
	link_button.uri = link_uri
	link_button.disabled = link_uri.is_empty()
