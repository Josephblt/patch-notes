class_name MobileInput
extends Node


@onready var _open_close_input_button: Button = %OpenCloseInputButton
@onready var _input_panel_container: Control = %InputPanelContainer


func _ready() -> void:
	_open_close_input_button.visible = Web.is_touch_web()


func _trigger_input_action(action_name: String) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)

	var release := InputEventAction.new()
	release.action = action_name
	release.pressed = false
	Input.parse_input_event(release)


func _on_button_toggled(toggled_on: bool) -> void:
	_input_panel_container.visible = toggled_on


func _on_esc_button_pressed() -> void:
	_trigger_input_action("bios_exit")


func _on_enter_button_pressed() -> void:
	_trigger_input_action("bios_accept")
	_trigger_input_action("bios_execute_command")


func _on_space_button_pressed() -> void:
	_trigger_input_action("bios_select")


func _on_right_button_pressed() -> void:
	_trigger_input_action("bios_right")


func _on_down_button_pressed() -> void:
	_trigger_input_action("bios_down")


func _on_left_button_pressed() -> void:
	_trigger_input_action("bios_left")


func _on_plus_button_pressed() -> void:
	_trigger_input_action("bios_add")


func _on_up_button_pressed() -> void:
	_trigger_input_action("bios_up")


func _on_minus_button_pressed() -> void:
	_trigger_input_action("bios_subtract")


func _on_f10_button_pressed() -> void:
	_trigger_input_action("bios_save_exit")


func _on_f9_button_pressed() -> void:
	_trigger_input_action("bios_setup_defaults")
