class_name BiosScene
extends CanvasLayer


enum Tabs {
	VERSION,
	CREDITS,
	EXIT
}

enum ExitOptions {
	EXIT_SAVING,
	EXIT_DISCARDING,
	LOAD_SETUP_DEFAULTS,
	DISCARD,
	SAVE
}


const STARTUP_SCENE: String = "res://scenes/startup.tscn"
const SELECTED_TAB_BG_COLOR: Color = Color(0xc0c0c0ff)
const SELECTED_TAB_TEXT_COLOR: Color = Color.BLUE
const SELECTED_ITEM_TEXT_COLOR: Color = Color.WHITE
const DESELECTED_TAB_BG_COLOR: Color = Color.BLUE
const DESELECTED_TAB_TEXT_COLOR: Color = Color(0xc0c0c0ff)
const DESELECTED_ITEM_TEXT_COLOR: Color = Color.BLUE

@onready var _version_panel_container: PanelContainer = %VersionPanelContainer
@onready var _version_label: Label = %VersionLabel
@onready var _credits_panel_container: PanelContainer = %CreditsPanelContainer
@onready var _credits_label: Label = %CreditsLabel
@onready var _exit_panel_container: PanelContainer = %ExitPanelContainer
@onready var _exit_label: Label = %ExitLabel
@onready var _exit_hbox_container: HBoxContainer = %ExitHBoxContainer
@onready var _exit_saving_changes_label: Label = %ExitSavingChangesLabel
@onready var _exit_discarding_changes_label: Label = %ExitDiscardingChangesLabel
@onready var _load_setup_defaults_label: Label = %LoadSetupDefaultsLabel
@onready var _discard_changes_label: Label = %DiscardChangesLabel
@onready var _save_changes_label: Label = %SaveChangesLabel
@onready var _exit_help_line_1: Label = %ExitHelpLine1
@onready var _exit_help_line_2: Label = %ExitHelpLine2
@onready var _exit_help_line_3: Label = %ExitHelpLine3

var _current_tab: Tabs = Tabs.VERSION
var _current_exit_option: ExitOptions = ExitOptions.EXIT_SAVING

func _ready() -> void:
	_update_tab(0)
	_update_exit_item(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(STARTUP_SCENE)
	
	if event.is_action_pressed("ui_left"):
		_update_tab(-1)

	if event.is_action_pressed("ui_right"):
		_update_tab(+1)
	

	if event.is_action_pressed("ui_up"):
		_update_item(-1)
	
	if event.is_action_pressed("ui_down"):
		_update_item(+1)
	

func _update_tab(direction: int) -> void:
	_current_tab = posmod(int(_current_tab) + direction, Tabs.size()) as Tabs
	match _current_tab:
		Tabs.VERSION:
			_select_tab(_version_panel_container, _version_label)
			_deselect_tab(_credits_panel_container, _credits_label)
			_deselect_tab(_exit_panel_container, _exit_label)
			_exit_hbox_container.visible = false
		Tabs.CREDITS:
			_deselect_tab(_version_panel_container, _version_label)
			_select_tab(_credits_panel_container, _credits_label)
			_deselect_tab(_exit_panel_container, _exit_label)
			_exit_hbox_container.visible = false
		Tabs.EXIT:
			_deselect_tab(_version_panel_container, _version_label)
			_deselect_tab(_credits_panel_container, _credits_label)
			_select_tab(_exit_panel_container, _exit_label)
			_exit_hbox_container.visible = true


func _update_item(direction: int) -> void:
	match _current_tab:
		Tabs.VERSION:
			pass
		Tabs.CREDITS:
			pass
		Tabs.EXIT:
			_update_exit_item(direction)


func _update_exit_item(direction: int) -> void:
	_current_exit_option = posmod(int(_current_exit_option) + direction, ExitOptions.size()) as ExitOptions
	match _current_exit_option:
		ExitOptions.EXIT_SAVING:
			_select_exit_option(_exit_saving_changes_label)
			_deselect_exit_option(_exit_discarding_changes_label)
			_deselect_exit_option(_load_setup_defaults_label)
			_deselect_exit_option(_discard_changes_label)
			_deselect_exit_option(_save_changes_label)
			_exit_help_line_1.text = "   Exit System Setup and"
			_exit_help_line_2.text = "   save your changes to"
			_exit_help_line_3.text = "   CMOS."
		ExitOptions.EXIT_DISCARDING:
			_deselect_exit_option(_exit_saving_changes_label)
			_select_exit_option(_exit_discarding_changes_label)
			_deselect_exit_option(_load_setup_defaults_label)
			_deselect_exit_option(_discard_changes_label)
			_deselect_exit_option(_save_changes_label)
			_exit_help_line_1.text = "   Exit utility without"
			_exit_help_line_2.text = "   saving Setup data to"
			_exit_help_line_3.text = "   CMOS."
		ExitOptions.LOAD_SETUP_DEFAULTS:
			_deselect_exit_option(_exit_saving_changes_label)
			_deselect_exit_option(_exit_discarding_changes_label)
			_select_exit_option(_load_setup_defaults_label)
			_deselect_exit_option(_discard_changes_label)
			_deselect_exit_option(_save_changes_label)
			_exit_help_line_1.text = "   Load default values"
			_exit_help_line_2.text = "   for all SETUP items."
			_exit_help_line_3.text = ""
		ExitOptions.DISCARD:
			_deselect_exit_option(_exit_saving_changes_label)
			_deselect_exit_option(_exit_discarding_changes_label)
			_deselect_exit_option(_load_setup_defaults_label)
			_select_exit_option(_discard_changes_label)
			_deselect_exit_option(_save_changes_label)
			_exit_help_line_1.text = "   Load previous values"
			_exit_help_line_2.text = "   from CMOS for all"
			_exit_help_line_3.text = "   SETUP items."
		ExitOptions.SAVE:
			_deselect_exit_option(_exit_saving_changes_label)
			_deselect_exit_option(_exit_discarding_changes_label)
			_deselect_exit_option(_load_setup_defaults_label)
			_deselect_exit_option(_discard_changes_label)
			_select_exit_option(_save_changes_label)
			_exit_help_line_1.text = "   Save Setup Data to"
			_exit_help_line_2.text = "   CMOS."
			_exit_help_line_3.text = ""


func _select_tab(panel_container: PanelContainer, label: Label) -> void:
	var stylebox := panel_container.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = SELECTED_TAB_BG_COLOR
	panel_container.add_theme_stylebox_override("panel", stylebox)
	label.add_theme_color_override("font_color", SELECTED_TAB_TEXT_COLOR)


func _deselect_tab(panel_container: PanelContainer, label: Label) -> void:
	var stylebox := panel_container.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = DESELECTED_TAB_BG_COLOR
	panel_container.add_theme_stylebox_override("panel", stylebox)
	label.add_theme_color_override("font_color", DESELECTED_TAB_TEXT_COLOR)


func _select_exit_option(label: Label) -> void:
	label.add_theme_color_override("font_color", SELECTED_ITEM_TEXT_COLOR)


func _deselect_exit_option(label: Label) -> void:
	label.add_theme_color_override("font_color", DESELECTED_ITEM_TEXT_COLOR)
