class_name StartupScene
extends CanvasLayer


const BIOS_SCENE: String = "uid://cs0ndb8p2joey"
const LOGIN_SCENE: String = "uid://bfpufq7f4feqv"
const STARTUP_MESSAGE: String = "To interrupt normal startup, press ENTER.\nJosephBLT Games (tm), 2026"
const WEB_BOOT_MESSAGE: String = "Press ENTER or tap to boot.\nJosephBLT Games (tm), 2026"

@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer
@onready var _interrupt_message: Label = %InterruptMessage

var _bios_enabled: bool = false
var _boot_started: bool = false


func _ready() -> void:
	if OS.has_feature("web"):
		_interrupt_message.text = WEB_BOOT_MESSAGE
		return

	_start_boot()


func _input(event: InputEvent) -> void:
	if not _boot_started:
		if _is_boot_event(event):
			_start_boot()
			get_viewport().set_input_as_handled()
		return

	if _bios_enabled and event.is_action_pressed("ui_accept"):
		_animation_player.stop()
		await get_tree().create_timer(1.0).timeout
		change_to_bios()


func _is_boot_event(event: InputEvent) -> bool:
	if event.is_action_pressed("ui_accept"):
		return true

	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		return mouse_event.pressed

	if event is InputEventScreenTouch:
		var touch_event := event as InputEventScreenTouch
		return touch_event.pressed

	return false


func _start_boot() -> void:
	_boot_started = true
	_interrupt_message.text = STARTUP_MESSAGE
	_audio_stream_player.play()
	_animation_player.play("startup_sequence")


func change_to_bios() -> void:
	get_tree().change_scene_to_file(BIOS_SCENE)


func change_to_login() -> void:
	get_tree().change_scene_to_file(LOGIN_SCENE)


func enable_bios() -> void:
	_bios_enabled = true


func disable_bios() -> void:
	_bios_enabled = false
