class_name BiosDialog
extends BiosItem


enum DialogOptions {
	YES,
	NO
}


signal dialog_closed(dialog_result: DialogOptions)


const SELECTED_OPTION_TEXT_COLOR: Color = Color.WHITE
const SELECTED_OPTION_BG_COLOR: Color = Color.BLACK
const DESELECTED_OPTION_BG_COLOR: Color = Color.WHITE
const DESELECTED_OPTION_TEXT_COLOR: Color = Color.BLUE

@onready var _yes_label: Label = %YesLabel
@onready var _no_label: Label = %NoLabel

var _current_option: DialogOptions = DialogOptions.NO


func _select() -> bool:
	_current_option = posmod(int(_current_option) + 1, DialogOptions.size()) as DialogOptions
	_update_option(_current_option)
	return true


func _accept() -> bool:
	deactivate()
	emit_signal("dialog_closed", _current_option)
	return true


func _update_option(option: DialogOptions) -> void:
	match option:
		DialogOptions.YES:
			_highlight(_yes_label)
			_unhilight(_no_label)
		DialogOptions.NO:
			_unhilight(_yes_label)
			_highlight(_no_label)


func _highlight(label: Label) -> void:
	var stylebox := label.get_theme_stylebox("normal").duplicate()
	stylebox.bg_color = SELECTED_OPTION_BG_COLOR
	label.add_theme_stylebox_override("normal", stylebox)
	label.add_theme_color_override("font_color", SELECTED_OPTION_TEXT_COLOR)


func _unhilight(label: Label) -> void:
	var stylebox := label.get_theme_stylebox("normal").duplicate()
	stylebox.bg_color = DESELECTED_OPTION_BG_COLOR
	label.add_theme_stylebox_override("normal", stylebox)
	label.add_theme_color_override("font_color", DESELECTED_OPTION_TEXT_COLOR)


func _reset() -> void:
	_current_option = DialogOptions.NO
	_update_option(_current_option)


func activate() -> void:
	_reset()
	super.activate()
