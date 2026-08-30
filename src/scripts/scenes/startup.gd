class_name StartupScene
extends CanvasLayer


const BIOS_SCENE: String = "uid://cs0ndb8p2joey"
const OS_LOAD_SCENE: String = "uid://ddk5w2icivnki"
const BIOS_SETUP_PROMPT_KEYBOARD: StringName = &"BIOS_SETUP_PROMPT_KEYBOARD"
const BIOS_SETUP_PROMPT_TOUCH: StringName = &"BIOS_SETUP_PROMPT_TOUCH"
const BIOS_SETUP_PROMPT_KEYBOARD_FALLBACK: String = "To interrupt normal startup, press ENTER.\nJosephBLT Games (tm), 2026"
const BIOS_SETUP_PROMPT_TOUCH_FALLBACK: String = "To interrupt normal startup, tap the SCREEN.\nJosephBLT Games (tm), 2026"

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _interrupt_message: Label = %InterruptMessage

var _bios_enabled: bool = false
var _startup_interrupted: bool = false


func _ready() -> void:
	_update_interrupt_message()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_update_interrupt_message()


func _input(event: InputEvent) -> void:
	if _bios_enabled and not _startup_interrupted and _is_bios_interrupt_event(event):
		_startup_interrupted = true
		_animation_player.stop()
		await get_tree().create_timer(1.0).timeout

		if is_inside_tree():
			change_to_bios()


func change_to_bios() -> void:
	get_tree().change_scene_to_file(BIOS_SCENE)


func change_to_os_load() -> void:
	get_tree().change_scene_to_file(OS_LOAD_SCENE)


func enable_bios() -> void:
	_bios_enabled = true


func disable_bios() -> void:
	_bios_enabled = false


func _is_bios_interrupt_event(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_accept"):
		return true

	if event is InputEventScreenTouch:
		return event.pressed

	if event is InputEventMouseButton:
		return Web.is_touch_web() and event.pressed and event.button_index == MOUSE_BUTTON_LEFT

	return false


func _update_interrupt_message() -> void:
	if _interrupt_message == null:
		return

	if Web.is_touch_web():
		_interrupt_message.text = _translate_or_fallback(BIOS_SETUP_PROMPT_TOUCH, BIOS_SETUP_PROMPT_TOUCH_FALLBACK)
	else:
		_interrupt_message.text = _translate_or_fallback(BIOS_SETUP_PROMPT_KEYBOARD, BIOS_SETUP_PROMPT_KEYBOARD_FALLBACK)


func _translate_or_fallback(key: StringName, fallback: String) -> String:
	var translated_text: String = tr(key)
	if translated_text == String(key):
		return fallback

	return translated_text
