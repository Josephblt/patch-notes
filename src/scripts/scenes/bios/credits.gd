class_name BiosCredits
extends BiosItem


@onready var _credits_left_vbox_container: VBoxContainer = %CreditsLeftVBoxContainer
@onready var _top_credits_line: Control = %TopCreditsLine
@onready var _top_credits_line_arrow: Control = %TopCreditsLineArrow
@onready var _bottom_credits_line: Control = %BottomCreditsLine
@onready var _bottom_credits_line_arrow: Control = %BottomCreditsLineArrow

var _credits_lines: Array[Control] = []
var _credits_visible_lines: int = 0
var _credits_hidden_lines: int = 0
var _current_credits_position: int = 0


func _ready():
	_load_credits_lines()


func _load_credits_lines() -> void:
	_credits_lines.clear()
	for child in _credits_left_vbox_container.get_children():
		if child.name.begins_with("CreditsLine"):
			if child.visible:
				_credits_visible_lines += 1
			_credits_lines.append(child)
	_credits_hidden_lines = _credits_lines.size() - _credits_visible_lines


func _select_item(direction: int) -> void:
	_current_credits_position += direction
	_current_credits_position = clamp(_current_credits_position, 0, _credits_hidden_lines)

	var outter_top = _current_credits_position - 1
	var top = _current_credits_position
	var bottom = _current_credits_position + _credits_visible_lines - 1
	var outter_bottom = _current_credits_position + _credits_visible_lines
		
	if outter_top >= 0:
		_credits_lines[outter_top].visible = false
	
	if top >= 0:
		_credits_lines[top].visible = true
	
	if bottom < _credits_lines.size():
		_credits_lines[bottom].visible = true
	
	if outter_bottom < _credits_lines.size():
		_credits_lines[outter_bottom].visible = false
	
	_top_credits_line.visible = top == 0
	_top_credits_line_arrow.visible = top > 0
	
	_bottom_credits_line.visible = bottom == _credits_lines.size() - 1
	_bottom_credits_line_arrow.visible = bottom < _credits_lines.size() - 1