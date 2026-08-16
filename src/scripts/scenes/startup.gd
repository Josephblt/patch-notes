class_name StartupScene
extends CanvasLayer


const BIOS_SCENE: String = "uid://cs0ndb8p2joey"
const LOGIN_SCENE: String = "uid://bfpufq7f4feqv"

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

var _bios_enabled: bool = false


func _input(event: InputEvent) -> void:
	if _bios_enabled and event.is_action_pressed("ui_accept"):
		_animation_player.stop()
		await get_tree().create_timer(1.0).timeout
		change_to_bios()


func change_to_bios() -> void:
	get_tree().change_scene_to_file(BIOS_SCENE)


func change_to_login() -> void:
	get_tree().change_scene_to_file(LOGIN_SCENE)


func enable_bios() -> void:
	_bios_enabled = true


func disable_bios() -> void:
	_bios_enabled = false
