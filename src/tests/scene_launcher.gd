extends CanvasLayer


const BALANCE_RUNNER_SCENE: String = "res://scenes/tools/balance_runner.tscn"
const TEST_SCENE: String = "res://scenes/test_scene.tscn"

@onready var balance_runner_button: Button = $MarginContainer/VBoxContainer/BalanceRunnerButton
@onready var test_scene_button: Button = $MarginContainer/VBoxContainer/TestSceneButton


func _ready() -> void:
	balance_runner_button.pressed.connect(_on_balance_runner_button_pressed)
	test_scene_button.pressed.connect(_on_test_scene_button_pressed)


func _on_balance_runner_button_pressed() -> void:
	get_tree().change_scene_to_file(BALANCE_RUNNER_SCENE)


func _on_test_scene_button_pressed() -> void:
	get_tree().change_scene_to_file(TEST_SCENE)
