class_name BiosScene
extends CanvasLayer


enum Modes {
	NORMAL,
	DIALOG
}


const STARTUP_SCENE: String = "uid://cbqyni481py2c"

@onready var _bios_menu: BiosMenu = %Menu
@onready var _bios_version: BiosVersion = %Version
@onready var _bios_credits: BiosCredits = %Credits
@onready var _bios_exit: BiosExit = %Exit
@onready var _bios_normal_keys: BiosNormalKeys = %NormalKeys
@onready var _bios_dialog_keys: BiosDialogKeys = %DialogKeys

@onready var _bios_exit_saving_dialog: BiosDialog = %ExitSavingDialog
@onready var _bios_exit_discarding_dialog: BiosDialog = %ExitDiscardingDialog
@onready var _bios_load_setup_defaults_dialog: BiosDialog = %LoadSetupDefaultsDialog
@onready var _bios_discard_changes_dialog: BiosDialog = %DiscardChangesDialog
@onready var _bios_save_changes_dialog: BiosDialog = %SaveChangesDialog

@onready var _mobile_input: MobileInput = %MobileInput

var mode: Modes = Modes.NORMAL


func _ready() -> void:
	_mobile_input.visible = !Web.is_touch_web()
	_enter_normal_mode()


func _enter_dialog_mode() -> void:
	_bios_menu.pause()
	_bios_version.pause()
	_bios_credits.pause()
	_bios_exit.pause()
	_bios_normal_keys.deactivate()
	_bios_dialog_keys.activate()
	mode = Modes.DIALOG


func _enter_normal_mode() -> void:
	_bios_menu.resume()
	_bios_version.resume()
	_bios_credits.resume()
	_bios_exit.resume()
	_bios_normal_keys.activate()
	_bios_dialog_keys.deactivate()
	mode = Modes.NORMAL


func _exit() -> void:
	get_tree().change_scene_to_file(STARTUP_SCENE)


func _load_setup_defaults() -> void:
	push_error("Load setup defaults functionality not implemented yet.")


func _discard() -> void:
	push_error("Discard functionality not implemented yet.")


func _save() -> void:
	push_error("Save functionality not implemented yet.")


func open_exit_saving_dialog() -> void:
	_enter_dialog_mode()
	_bios_exit_saving_dialog.activate()
	var dialog_result = await _bios_exit_saving_dialog.dialog_closed
	
	match dialog_result:
		BiosDialog.DialogOptions.YES:
			_save()
			_exit()
		BiosDialog.DialogOptions.NO:
			_enter_normal_mode()


func open_exit_discarding_dialog() -> void:
	_enter_dialog_mode()
	_bios_exit_discarding_dialog.activate()
	var dialog_result = await _bios_exit_discarding_dialog.dialog_closed
		
	match dialog_result:
		BiosDialog.DialogOptions.YES:
			_exit()
		BiosDialog.DialogOptions.NO:
			_enter_normal_mode()


func open_load_setup_defaults_dialog() -> void:
	_enter_dialog_mode()
	_bios_load_setup_defaults_dialog.activate()
	var dialog_result = await _bios_load_setup_defaults_dialog.dialog_closed
		
	match dialog_result:
		BiosDialog.DialogOptions.YES:
			_load_setup_defaults()

	_enter_normal_mode()


func open_discard_changes_dialog() -> void:
	_enter_dialog_mode()
	_bios_discard_changes_dialog.activate()
	var dialog_result = await _bios_discard_changes_dialog.dialog_closed
		
	match dialog_result:
		BiosDialog.DialogOptions.YES:
			_discard()
		
	_enter_normal_mode()


func open_save_changes_dialog() -> void:
	_enter_dialog_mode()
	_bios_save_changes_dialog.activate()
	var dialog_result = await _bios_save_changes_dialog.dialog_closed
		
	match dialog_result:
		BiosDialog.DialogOptions.YES:
			_save()
	
	_enter_normal_mode()


func _on_menu_changed(menu: BiosMenu.Menus) -> void:
	match menu:
		BiosMenu.Menus.VERSION:
			_bios_version.activate()
			_bios_credits.deactivate()
			_bios_exit.deactivate()
		BiosMenu.Menus.CREDITS:
			_bios_version.deactivate()
			_bios_credits.activate()
			_bios_exit.deactivate()
		BiosMenu.Menus.EXIT:
			_bios_version.deactivate()
			_bios_credits.deactivate()
			_bios_exit.activate()
	