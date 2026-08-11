class_name BiosNormalKeys
extends BiosItem


@export var _bios_scene: BiosScene = get_parent() as BiosScene


func _exit() -> void:
	_bios_scene.open_exit_discarding_dialog()


func _setup_defaults() -> void:
	_bios_scene.open_load_setup_defaults_dialog()


func _save_exit() -> void:
	_bios_scene.open_exit_saving_dialog()
