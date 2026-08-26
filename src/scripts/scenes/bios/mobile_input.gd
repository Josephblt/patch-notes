class_name MobileInput
extends Node

@export var _bios: BiosScene

# func _trigger_input_action(action_name: String) -> void:
# 	call_deferred("_parse_input_action", action_name)


func _trigger_input_action(action_name: String) -> void:
	var event := InputEventAction.new()
	event.action = action_name
	event.pressed = true
	Input.parse_input_event(event)

	var release := InputEventAction.new()
	release.action = action_name
	release.pressed = false
	Input.parse_input_event(release)


func _on_esc_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_exit")


func _on_enter_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.DIALOG:
		_trigger_input_action("bios_accept")
	else:
		_trigger_input_action("bios_execute_command")
	

func _on_space_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.DIALOG:
		_trigger_input_action("bios_select")


func _on_right_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_right")


func _on_down_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_down")


func _on_left_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_left")


func _on_plus_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_add")


func _on_up_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_up")


func _on_minus_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_subtract")


func _on_f10_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_save_exit")


func _on_f9_button_pressed() -> void:
	if _bios.mode == BiosScene.Modes.NORMAL:
		_trigger_input_action("bios_setup_defaults")
