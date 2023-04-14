extends AnimatedSprite2D


@export var speed := 1.0

var finished_requirement: int = 2
var finished_count: int = 0

func explode(ps: float = 1.0) -> void:
	$ExplosionSound.pitch_scale = ps
	$ExplosionSound.play()


func _physics_process(delta) -> void:
	position.x -= speed


func _on_animation_finished() -> void:
	increment_finished()


func _on_explosion_sound_finished() -> void:
	increment_finished()

func increment_finished() -> void:
	finished_count += 1
	
	if finished_count == finished_requirement:
		queue_free()
