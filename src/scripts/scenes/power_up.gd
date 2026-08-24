class_name PowerUpScene
extends CanvasLayer


const STARTUP_SCENE: String = "uid://cbqyni481py2c"

@export var follow_offset: Vector2 = Vector2(150, 150)

@onready var _button: TextureButton = %ButtonTextureButton
@onready var _finger: TextureRect = %FingerTextureRect
@onready var _animation_player: AnimationPlayer = %AnimationPlayer
@onready var _button_down_click_player: AudioStreamPlayer = %ButtonDownClickPlayer
@onready var _button_up_click_player: AudioStreamPlayer = %ButtonUpClickPlayer


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_update_finger_position(event.position)


func _update_finger_position(mouse_position: Vector2) -> void:
	var button_bounds: Rect2 = _button.get_global_rect()
	var finger_bounds: Rect2 = Rect2(mouse_position - follow_offset, follow_offset * 2)
	
	if finger_bounds.position.x < button_bounds.position.x:
		finger_bounds.position.x = button_bounds.position.x
	
	if finger_bounds.end.x > button_bounds.end.x:
		finger_bounds.position.x = button_bounds.end.x - finger_bounds.size.x
	
	if finger_bounds.position.y < button_bounds.position.y:
		finger_bounds.position.y = button_bounds.position.y
	
	if finger_bounds.end.y > button_bounds.end.y:
		finger_bounds.position.y = button_bounds.end.y - finger_bounds.size.y
	
	_finger.global_position = finger_bounds.position


func _power_up() -> void:
	_button.disabled = true
	_animation_player.play_backwards("fade")
	await _animation_player.animation_finished
	
	print("Power up complete, returning to startup scene.")
	get_tree().change_scene_to_file(STARTUP_SCENE)


func _on_button_up() -> void:
	_button_up_click_player.play()
	_power_up()


func _on_button_down() -> void:
	_button_down_click_player.play()
