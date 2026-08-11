class_name BiosItem
extends Container


var _paused: bool = true


func _input(event: InputEvent) -> void:
	if _paused:
		return
	
	if not visible:
		return
	
	
	if event.is_action_pressed("bios_exit"):
		_exit()
	if event.is_action_pressed("bios_left"):
		_select_menu(-1)
	if event.is_action_pressed("bios_right"):
		_select_menu(1)
	if event.is_action_pressed("bios_up"):
		_select_item(-1)
	if event.is_action_pressed("bios_down"):
		_select_item(1)
	if event.is_action_pressed("bios_subtract"):
		_change_value(-1)
	if event.is_action_pressed("bios_add"):
		_change_value(1)
	if event.is_action_pressed("bios_execute_command"):
		_execute_command()
	if event.is_action_pressed("bios_select"):
		_select()
	if event.is_action_pressed("bios_accept"):
		_accept()
	if event.is_action_pressed("bios_setup_defaults"):
		_setup_defaults()
	if event.is_action_pressed("bios_save_exit"):
		_save_exit()


func _exit() -> void:
	pass


func _select_menu(_direction: int) -> void:
	pass


func _select_item(_direction: int) -> void:
	pass


func _change_value(_direction: int) -> void:
	pass


func _execute_command() -> void:
	pass


func _setup_defaults() -> void:
	pass


func _save_exit() -> void:
	pass


func _select() -> void:
	pass


func _accept() -> void:
	pass


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
