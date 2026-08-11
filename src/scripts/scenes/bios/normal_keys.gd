class_name BiosNormalKeys
extends BiosItem


@export var _bios_scene: BiosScene


func _exit() -> bool:
	_bios_scene.open_exit_discarding_dialog()
	return true


func _setup_defaults() -> bool:
	_bios_scene.open_load_setup_defaults_dialog()
	return true


func _save_exit() -> bool:
	_bios_scene.open_exit_saving_dialog()
	return true
