class_name BiosExit
extends BiosItem


enum ExitOptions {
	EXIT_SAVING,
	EXIT_DISCARDING,
	LOAD_SETUP_DEFAULTS,
	DISCARD,
	SAVE
}


const SELECTED_ITEM_TEXT_COLOR: Color = Color.WHITE
const DESELECTED_ITEM_TEXT_COLOR: Color = Color.BLUE

@export var _bios: BiosScene

@onready var _exit_saving_changes_label: Label = %ExitSavingChangesLabel
@onready var _exit_discarding_changes_label: Label = %ExitDiscardingChangesLabel
@onready var _load_setup_defaults_label: Label = %LoadSetupDefaultsLabel
@onready var _discard_changes_label: Label = %DiscardChangesLabel
@onready var _save_changes_label: Label = %SaveChangesLabel
@onready var _exit_help_line_1: Label = %ExitHelpLine1
@onready var _exit_help_line_2: Label = %ExitHelpLine2
@onready var _exit_help_line_3: Label = %ExitHelpLine3

var _current_exit_option: ExitOptions = ExitOptions.EXIT_SAVING


func _select_item(direction: int) -> void:
	_current_exit_option = posmod(int(_current_exit_option) + direction, ExitOptions.size()) as ExitOptions
	_update_selection(_current_exit_option)
	_update_help_lines(_current_exit_option)


func _execute_command() -> void:
	match _current_exit_option:
		ExitOptions.EXIT_SAVING:
			_bios.open_exit_saving_dialog()
		ExitOptions.EXIT_DISCARDING:
			_bios.open_exit_discarding_dialog()
		ExitOptions.LOAD_SETUP_DEFAULTS:
			_bios.open_load_setup_defaults_dialog()
		ExitOptions.DISCARD:
			_bios.open_discard_changes_dialog()
		ExitOptions.SAVE:
			_bios.open_save_changes_dialog()


func _update_selection(exit_option: ExitOptions) -> void:
	if exit_option == ExitOptions.EXIT_SAVING:
		_exit_saving_changes_label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)
	else:
		_exit_saving_changes_label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)
	
	if exit_option == ExitOptions.EXIT_DISCARDING:
		_exit_discarding_changes_label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)
	else:
		_exit_discarding_changes_label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)
	
	if exit_option == ExitOptions.LOAD_SETUP_DEFAULTS:
		_load_setup_defaults_label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)
	else:
		_load_setup_defaults_label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)
	
	if exit_option == ExitOptions.DISCARD:
		_discard_changes_label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)
	else:
		_discard_changes_label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)
	
	if exit_option == ExitOptions.SAVE:
		_save_changes_label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)
	else:
		_save_changes_label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)

	
func _update_help_lines(exit_option: ExitOptions) -> void:
	match exit_option:
		ExitOptions.EXIT_SAVING:
			_update_help_lines_for_exit_saving()
		ExitOptions.EXIT_DISCARDING:
			_update_help_lines_for_exit_discarding()
		ExitOptions.LOAD_SETUP_DEFAULTS:
			_update_help_lines_for_load_setup_defaults()
		ExitOptions.DISCARD:
			_update_help_lines_for_discard()
		ExitOptions.SAVE:
			_update_help_lines_for_save()


func _update_help_lines_for_exit_saving() -> void:
	_exit_help_line_1.text = "   Exit System Setup and"
	_exit_help_line_2.text = "   save your changes to"
	_exit_help_line_3.text = "   CMOS."


func _update_help_lines_for_exit_discarding() -> void:
	_exit_help_line_1.text = "   Exit utility without"
	_exit_help_line_2.text = "   saving Setup data to"
	_exit_help_line_3.text = "   CMOS."


func _update_help_lines_for_load_setup_defaults() -> void:
	_exit_help_line_1.text = "   Load default values"
	_exit_help_line_2.text = "   for all SETUP items."
	_exit_help_line_3.text = ""


func _update_help_lines_for_discard() -> void:
	_exit_help_line_1.text = "   Load previous values"
	_exit_help_line_2.text = "   from CMOS for all"
	_exit_help_line_3.text = "   SETUP items."


func _update_help_lines_for_save() -> void:
	_exit_help_line_1.text = "   Save Setup Data to"
	_exit_help_line_2.text = "   CMOS."
	_exit_help_line_3.text = ""
