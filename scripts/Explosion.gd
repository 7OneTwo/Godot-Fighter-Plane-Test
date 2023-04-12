extends AnimatedSprite2D


@export var speed := 1.0


func _physics_process(delta) -> void:
	position.x -= speed


func _on_animation_finished() -> void:
	queue_free()
