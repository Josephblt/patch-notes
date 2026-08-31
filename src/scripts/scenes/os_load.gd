class_name OSLoad
extends CanvasLayer


const LOGIN_SCENE: String = "uid://bfpufq7f4feqv"
const COPYRIGHT_MESSAGES: Array = [
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved when remembered.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved pending objection.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights assumed until proven otherwise.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved when legally convenient.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved until escalated.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless inconvenient.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved if challenged.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved subject to clerical error.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless regretted.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved until someone important asks.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless that becomes expensive.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless confidence changes.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved until denied politely.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless waived accidentally.",
	"Copyright (C) JOSEPHBLT GAMES, 2026.\nAll rights reserved unless claimed by someone louder."
]


@onready var _copyright: Label = %Copyright
@onready var _animation_player: AnimationPlayer = %AnimationPlayer


func _ready() -> void:
	_copyright.text = COPYRIGHT_MESSAGES[randi() % COPYRIGHT_MESSAGES.size()]


func change_to_login() -> void:
	_animation_player.play("fade_out")
	await _animation_player.animation_finished
	get_tree().change_scene_to_file(LOGIN_SCENE)
