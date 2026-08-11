class_name BiosItem
extends Container


var _paused: bool = true


func _input(event: InputEvent) -> void:
	if _paused:
		return
	
	if not visible:
		return
	
	if event.is_action_pressed("bios_exit") and _exit():
		_accept_event()
		return
	if event.is_action_pressed("bios_left") and _select_menu(-1):
		_accept_event()
		return
	if event.is_action_pressed("bios_right") and _select_menu(1):
		_accept_event()
		return
	if event.is_action_pressed("bios_up") and _select_item(-1):
		_accept_event()
		return
	if event.is_action_pressed("bios_down") and _select_item(1):
		_accept_event()
		return
	if event.is_action_pressed("bios_subtract") and _change_value(-1):
		_accept_event()
		return
	if event.is_action_pressed("bios_add") and _change_value(1):
		_accept_event()
		return
	if event.is_action_pressed("bios_execute_command") and _execute_command():
		_accept_event()
		return
	if event.is_action_pressed("bios_select") and _select():
		_accept_event()
		return
	if event.is_action_pressed("bios_accept") and _accept():
		_accept_event()
		return
	if event.is_action_pressed("bios_setup_defaults") and _setup_defaults():
		_accept_event()
		return
	if event.is_action_pressed("bios_save_exit") and _save_exit():
		_accept_event()
		return


func _accept_event() -> void:
	var viewport = get_viewport()
	if viewport:
		viewport.set_input_as_handled()


func _exit() -> bool:
	return false


func _select_menu(_direction: int) -> bool:
	return false


func _select_item(_direction: int) -> bool:
	return false


func _change_value(_direction: int) -> bool:
	return false


func _execute_command() -> bool:
	return false


func _setup_defaults() -> bool:
	return false


func _save_exit() -> bool:
	return false


func _select() -> bool:
	return false


func _accept() -> bool:
	return false


func activate() -> void:
	resume()
	visible = true


func deactivate() -> void:
	pause()
	visible = false


func resume() -> void:
	_paused = false


func pause() -> void:
	_paused = true
