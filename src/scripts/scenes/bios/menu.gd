class_name BiosMenu
extends BiosItem


enum Menus {
	VERSION,
	CREDITS,
	EXIT
}


signal menu_changed(new_menu: Menus)


const SELECTED_TAB_BG_COLOR: Color = Color(0xc0c0c0ff)
const SELECTED_TAB_TEXT_COLOR: Color = Color.BLUE
const DESELECTED_TAB_BG_COLOR: Color = Color.BLUE
const DESELECTED_TAB_TEXT_COLOR: Color = Color(0xc0c0c0ff)

@onready var _version_panel_container: PanelContainer = %VersionPanelContainer
@onready var _version_label: Label = %VersionLabel
@onready var _credits_panel_container: PanelContainer = %CreditsPanelContainer
@onready var _credits_label: Label = %CreditsLabel
@onready var _exit_panel_container: PanelContainer = %ExitPanelContainer
@onready var _exit_label: Label = %ExitLabel

var _current_menu: Menus = Menus.VERSION


func _select_menu(direction: int) -> void:
	_current_menu = posmod(int(_current_menu) + direction, Menus.size()) as Menus
	emit_signal("menu_changed", _current_menu)
		
	match _current_menu:
		Menus.VERSION:
			_highlight(_version_panel_container, _version_label)
			_unhilight(_credits_panel_container, _credits_label)
			_unhilight(_exit_panel_container, _exit_label)
		Menus.CREDITS:
			_unhilight(_version_panel_container, _version_label)
			_highlight(_credits_panel_container, _credits_label)
			_unhilight(_exit_panel_container, _exit_label)
		Menus.EXIT:
			_unhilight(_version_panel_container, _version_label)
			_unhilight(_credits_panel_container, _credits_label)
			_highlight(_exit_panel_container, _exit_label)


func _highlight(panel_container: PanelContainer, label: Label) -> void:
	var stylebox := panel_container.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = SELECTED_TAB_BG_COLOR
	panel_container.add_theme_stylebox_override("panel", stylebox)
	label.add_theme_color_override("font_color", SELECTED_TAB_TEXT_COLOR)


func _unhilight(panel_container: PanelContainer, label: Label) -> void:
	var stylebox := panel_container.get_theme_stylebox("panel").duplicate()
	stylebox.bg_color = DESELECTED_TAB_BG_COLOR
	panel_container.add_theme_stylebox_override("panel", stylebox)
	label.add_theme_color_override("font_color", DESELECTED_TAB_TEXT_COLOR)
