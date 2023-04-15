extends Node2D

@export var speed: float = 1000.0

@onready var shoot_sound := $SoundQueue

var movement_vector := Vector2(1, 0)

func _ready() -> void:
	shoot_sound.play_sound()


func _process(delta: float) -> void:
	global_position -= movement_vector.rotated(rotation) * speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
